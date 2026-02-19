class Validators {
  static bool isWithinRange(int value, {required int min, required int max}) {
    return value >= min && value <= max;
  }
}
