import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/constants/quran-meta.dart';

void main() {
  group('Day 6 - QuranMeta Lazy Cursor Tests', () {
    test('Generates next 3 new items identically (Deterministic)', () {
      final run1 = QuranMeta.generateNextNItems(
          currentSurah: 1, currentAyah: 1, amount: 3, targetEndSurah: 114);
      final run2 = QuranMeta.generateNextNItems(
          currentSurah: 1, currentAyah: 1, amount: 3, targetEndSurah: 114);

      // Must be identical
      expect(run1, run2);
      expect(run1, ['s1_a1', 's1_a2', 's1_a3']);
    });

    test('Cursor advances across Surah boundaries correctly', () {
      // Surah 1 has 7 ayahs.
      // Starting at s1_a6 and asking for 3 items should yield:
      // s1_a6, s1_a7, and then safely wrap to s2_a1.
      final result = QuranMeta.generateNextNItems(
          currentSurah: 1, currentAyah: 6, amount: 3, targetEndSurah: 114);

      expect(result, ['s1_a6', 's1_a7', 's2_a1']);
    });

    test('Stops generating safely if targetEndSurah is exceeded', () {
      // Surah 114 (An-Nas) has 6 ayahs.
      // Starting at s114_a5 and asking for 5 items should only yield 2 items
      // (a5, a6) and then stop because there is no Surah 115.
      final result = QuranMeta.generateNextNItems(
          currentSurah: 114, currentAyah: 5, amount: 5, targetEndSurah: 114);

      expect(result, ['s114_a5', 's114_a6']);
      expect(result.length, 2);
    });
  });
}
