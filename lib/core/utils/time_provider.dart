/// A pure Dart abstraction for time to ensure deterministic testing
/// and timezone-safe date calculations across the app.
abstract class TimeProvider {
  DateTime get nowUtc;
}

/// The production implementation that uses the real device clock.
class SystemTimeProvider implements TimeProvider {
  const SystemTimeProvider();

  @override
  DateTime get nowUtc => DateTime.now().toUtc();
}

/// The testing implementation that freezes time.
class FixedTimeProvider implements TimeProvider {
  final DateTime _fixedTime;

  const FixedTimeProvider(this._fixedTime);

  @override
  DateTime get nowUtc => _fixedTime.toUtc();
}
