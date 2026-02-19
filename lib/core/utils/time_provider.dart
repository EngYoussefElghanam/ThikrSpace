/// Abstraction over DateTime.now() to allow for easier testing later.
class TimeProvider {
  static DateTime get now => DateTime.now();
  static DateTime get nowUtc => DateTime.now().toUtc();
}
