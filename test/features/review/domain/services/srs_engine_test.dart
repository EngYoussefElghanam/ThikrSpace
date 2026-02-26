import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/utils/time_provider.dart';
import 'package:thikrspace_beta/features/review/domain/entities/srs_state.dart';
import 'package:thikrspace_beta/features/review/domain/services/srs_engine.dart';

// --- TIME MACHINE FOR TESTS ---
// Allows us to dynamically fast-forward time to simulate real usage
class MutableTimeProvider implements TimeProvider {
  DateTime _currentUtc;

  MutableTimeProvider(this._currentUtc);

  @override
  DateTime get nowUtc => _currentUtc;

  void advanceTo(DateTime newTime) {
    _currentUtc = newTime;
  }
}

void main() {
  group('Day 7 - SRS Engine Pure Logic Tests', () {
    final startOfTime =
        DateTime.utc(2026, 1, 1, 8, 0, 0); // Jan 1, 2026, 8:00 AM UTC
    late MutableTimeProvider timeMachine;
    late SrsEngine engine;

    setUp(() {
      timeMachine = MutableTimeProvider(startOfTime);
      engine = SrsEngine(timeMachine);
    });

    // --- YOUR MANUAL SANITY TEST ---
    test('Manual Sanity Timeline (Prints to Console)', () {
      print('\n=========================================');
      print('⏳ SRS MANUAL SANITY TIMELINE SIMULATION');
      print('=========================================');

      // 1. Start new item -> rate 5
      print(
          'Day 0 (${timeMachine.nowUtc.toString().substring(0, 10)}): Learning new item...');
      var state = engine.calculateNextState(current: null, rating: 5);
      print(
          '-> Rated 5 (Perfect). Interval: ${state.intervalDays} day. Due: ${state.dueAt.toString().substring(0, 10)}\n');

      expect(state.intervalDays, 1);

      // 2. Next day -> rate 5
      // Fast forward the clock to 8:00 AM on the exact day it is due!
      timeMachine.advanceTo(state.dueAt.add(const Duration(hours: 8)));
      print(
          'Day 1 (${timeMachine.nowUtc.toString().substring(0, 10)}): Reviewing item...');
      state = engine.calculateNextState(current: state, rating: 5);
      print(
          '-> Rated 5 (Perfect). Interval: ${state.intervalDays} days. Due: ${state.dueAt.toString().substring(0, 10)}\n');

      expect(state.intervalDays, 3);

      // 3. Next due -> rate 5
      // Fast forward again!
      timeMachine.advanceTo(state.dueAt.add(const Duration(hours: 8)));
      print(
          'Day 4 (${timeMachine.nowUtc.toString().substring(0, 10)}): Reviewing item...');
      state = engine.calculateNextState(current: state, rating: 5);
      print(
          '-> Rated 5 (Perfect). Interval: ${state.intervalDays} days. Due: ${state.dueAt.toString().substring(0, 10)}');

      expect(state.intervalDays, 8); // Grows correctly!
      print('=========================================\n');
    });

    // --- REGULAR EDGE CASE TESTS ---
    test('First review with rating 5 (Perfect)', () {
      final state = engine.calculateNextState(current: null, rating: 5);

      expect(state.ease, 2.6);
      expect(state.intervalDays, 1);
      expect(state.reps, 1);
      expect(state.lapses, 0);
      expect(state.dueAt, DateTime.utc(2026, 1, 2)); // Due tomorrow precisely
    });

    test('Lapse behavior: Rating 1 resets interval and increments lapses', () {
      final existingState = SrsState(
          ease: 2.5,
          intervalDays: 10,
          dueAt: startOfTime,
          reps: 2,
          lapses: 0,
          lastReviewedAt: startOfTime);

      final lapsedState =
          engine.calculateNextState(current: existingState, rating: 1);

      expect(lapsedState.intervalDays, 0);
      expect(lapsedState.reps, 0);
      expect(lapsedState.lapses, 1);
      expect(lapsedState.ease, 2.2);
      expect(lapsedState.dueAt, DateTime.utc(2026, 1, 1)); // Due today
    });

    test('Clamping: Ease and Interval do not breach boundaries', () {
      final extremeState = SrsState(
          ease: 1.3,
          intervalDays: 3500,
          dueAt: startOfTime,
          reps: 10,
          lapses: 5,
          lastReviewedAt: startOfTime);

      final clampedEaseState =
          engine.calculateNextState(current: extremeState, rating: 1);
      expect(clampedEaseState.ease, 1.3);

      final largeIntervalState = SrsState(
          ease: 2.7,
          intervalDays: 3000,
          dueAt: startOfTime,
          reps: 5,
          lapses: 0,
          lastReviewedAt: startOfTime);
      final clampedIntervalState =
          engine.calculateNextState(current: largeIntervalState, rating: 5);
      expect(clampedIntervalState.intervalDays, 3650);
    });
  });
}
