import '../../../../core/utils/time_provider.dart';
import '../entities/srs_state.dart';

/// Pure Dart SRS Engine (SM-2 Inspired)
///
/// Rating Rules:
/// 5 (Perfect) : ease + 0.10
/// 4 (Good)    : ease + 0.00
/// 3 (Hard)    : ease - 0.10
/// 2 (Lapse)   : ease - 0.20, interval resets to 0, lapses increment
/// 1 (Fail)    : ease - 0.30, interval resets to 0, lapses increment
///
/// Bounds:
/// - Ease is clamped between [1.3, 2.7]
/// - Interval is clamped at 3650 days (10 years)
class SrsEngine {
  // 1. Store the abstract interface, NOT the FixedTimeProvider.
  // This allows production to pass SystemTimeProvider, and tests to pass FixedTimeProvider.
  final TimeProvider timeProvider;

  SrsEngine(this.timeProvider);

  static const double _maxEase = 2.7;
  static const double _minEase = 1.3;
  static const int _maxIntervalDays = 3650;
  static const double _defaultEase = 2.5;

  // 2. Remove "static" and remove "nowUtc" from parameters
  SrsState calculateNextState({
    SrsState? current,
    required int rating,
  }) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be strictly between 1 and 5');
    }

    // 3. Grab the time directly from the injected provider!
    final nowUtc = timeProvider.nowUtc;

    // 1. Initial State Setup
    double ease = current?.ease ?? _defaultEase;
    int intervalDays = current?.intervalDays ?? 0;
    int reps = current?.reps ?? 0;
    int lapses = current?.lapses ?? 0;

    // 2. Ease Update
    switch (rating) {
      case 5:
        ease += 0.10;
        break;
      case 4:
        ease += 0.00;
        break;
      case 3:
        ease -= 0.10;
        break;
      case 2:
        ease -= 0.20;
        break;
      case 1:
        ease -= 0.30;
        break;
    }
    ease = ease.clamp(_minEase, _maxEase);

    // 3. Interval & Reps/Lapses Update
    if (rating == 1 || rating == 2) {
      intervalDays = 0;
      reps = 0;
      lapses += 1;
    } else {
      if (reps == 0) {
        intervalDays = 1;
      } else if (reps == 1) {
        intervalDays = 3;
      } else {
        intervalDays = (intervalDays * ease).round();
      }
      reps += 1;
    }

    if (intervalDays > _maxIntervalDays) {
      intervalDays = _maxIntervalDays;
    }

    // 4. Due Date Calculation
    final normalizedNow = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final dueAt = normalizedNow.add(Duration(days: intervalDays));

    return SrsState(
      ease: ease,
      intervalDays: intervalDays,
      dueAt: dueAt,
      reps: reps,
      lapses: lapses,
      lastReviewedAt: nowUtc,
    );
  }
}
