class IdGenerator {
  /// Generates a deterministic item ID based on Surah and Ayah.
  static String generateItemId({required int surah, required int ayah}) {
    return 's${surah}_a$ayah';
  }
}
