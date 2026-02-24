class QuranMeta {
  // Index 0 represents Surah 1 (Al-Fatihah), Index 113 represents Surah 114 (An-Nas).
  // This structural data allows deterministic cursor advancement without needing a heavy Quran text library.
  static const List<int> ayahCounts = [
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

  static int getAyahCount(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError('Surah number must be between 1 and 114');
    }
    return ayahCounts[surahNumber - 1];
  }

  // Pure Dart deterministic function to calculate the next N items
  static List<String> generateNextNItems({
    required int currentSurah,
    required int currentAyah,
    required int amount,
    required int targetEndSurah,
  }) {
    List<String> nextItems = [];
    int s = currentSurah;
    int a = currentAyah;

    for (int i = 0; i < amount; i++) {
      if (s > targetEndSurah) break; // Reached the user's final goal

      nextItems.add('s${s}_a$a'); // Generates deterministic ID: s1_a1

      a++; // Move to next ayah
      if (a > getAyahCount(s)) {
        s++; // Move to next surah
        a = 1; // Reset to first ayah
      }
    }
    return nextItems;
  }
}
