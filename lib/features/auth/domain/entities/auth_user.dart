class AuthUser {
  final String id;
  final String email;
  final String name;
  // --- Lazy Item Meta (Day 6) ---
  final int cursorSurah; // The Surah of the next new item to learn
  final int cursorAyah; // The Ayah of the next new item to learn
  final int targetEndSurah; // The user's goal (e.g., 114)
  AuthUser(
      {required this.id,
      required this.email,
      required this.name,
      required this.cursorSurah,
      required this.cursorAyah,
      required this.targetEndSurah});
}
