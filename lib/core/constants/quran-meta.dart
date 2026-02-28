/// Core constants and cursor utilities for Quran navigation.
/// Pure Dart. No Flutter imports.
class QuranMeta {
  /// The exact number of ayahs in each of the 114 Surahs.
  /// Index 0 = Surah 1 (Al-Fatiha), Index 113 = Surah 114 (An-Nas).
  static const List<int> surahAyahCounts = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6
  ];

  static int getAyahCount(int surah) {
    if (surah < 1 || surah > 114) throw ArgumentError('Invalid surah: $surah');
    return surahAyahCounts[surah - 1];
  }

  /// Advances the cursor to the next Ayah.
  /// Automatically handles Surah boundaries and respects the target range (forwards or backwards).
  /// Returns null if the user has completed their target range.
  static Cursor? advanceCursor(Cursor current, int startSurah, int endSurah) {
    bool isBackwards = startSurah > endSurah;
    int nextAyah = current.ayah + 1;
    int nextSurah = current.surah;

    // Boundary check: Did we finish the current Surah?
    if (nextAyah > getAyahCount(current.surah)) {
      nextAyah = 1; // Always reset to Ayah 1 of the new Surah
      nextSurah = isBackwards ? current.surah - 1 : current.surah + 1;
    }

    // Range check: Did we finish the target range?
    if (isBackwards && nextSurah < endSurah) return null;
    if (!isBackwards && nextSurah > endSurah) return null;

    // Safety bounds just in case
    if (nextSurah < 1 || nextSurah > 114) return null;

    return Cursor(surah: nextSurah, ayah: nextAyah);
  }

  /// Validates if the cursor is within the current range.
  /// If out of bounds, returns a reset cursor at Ayah 1 of the startSurah.
  static Cursor clampCursorToRange(
      Cursor current, int startSurah, int endSurah) {
    bool isBackwards = startSurah > endSurah;
    if (isBackwards) {
      if (current.surah > startSurah || current.surah < endSurah)
        return Cursor(surah: startSurah, ayah: 1);
    } else {
      if (current.surah < startSurah || current.surah > endSurah)
        return Cursor(surah: startSurah, ayah: 1);
    }
    return current;
  }
}

// Simple immutable data classes for the domain
class Cursor {
  final int surah;
  final int ayah;
  const Cursor({required this.surah, required this.ayah});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cursor && surah == other.surah && ayah == other.ayah;
  @override
  int get hashCode => surah.hashCode ^ ayah.hashCode;
  @override
  String toString() => 'Cursor(s$surah:a$ayah)';
}
