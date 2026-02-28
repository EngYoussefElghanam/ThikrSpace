import 'package:flutter_test/flutter_test.dart';
// Note: Ensure your file name matches your actual import path!
// (e.g., quran_meta.dart instead of quran-meta.dart if you used underscores)
import 'package:thikrspace_beta/core/constants/quran-meta.dart';

void main() {
  group('Day 8 - QuranMeta Cursor Logic Tests', () {
    test('getAyahCount returns correct counts', () {
      expect(QuranMeta.getAyahCount(1), 7); // Al-Fatiha
      expect(QuranMeta.getAyahCount(2), 286); // Al-Baqarah
      expect(QuranMeta.getAyahCount(114), 6); // An-Nas
    });

    test('advanceCursor moves forward and crosses boundaries safely', () {
      // Start at Surah 1, Ayah 6. Target range: 1 -> 114 (Forwards)
      var cursor = const Cursor(surah: 1, ayah: 6);

      cursor = QuranMeta.advanceCursor(cursor, 1, 114)!;
      expect(cursor, const Cursor(surah: 1, ayah: 7));

      // Crossing the boundary! Surah 1 only has 7 ayahs.
      cursor = QuranMeta.advanceCursor(cursor, 1, 114)!;
      expect(cursor, const Cursor(surah: 2, ayah: 1));
    });

    test('advanceCursor moves backwards and crosses boundaries safely', () {
      // Start at Surah 114, Ayah 5. Target range: 114 -> 1 (Backwards)
      var cursor = const Cursor(surah: 114, ayah: 5);

      cursor = QuranMeta.advanceCursor(cursor, 114, 1)!;
      expect(cursor, const Cursor(surah: 114, ayah: 6)); // Ayahs always go up

      // Crossing the boundary! Drops down to Surah 113, Ayah 1.
      cursor = QuranMeta.advanceCursor(cursor, 114, 1)!;
      expect(cursor, const Cursor(surah: 113, ayah: 1));
    });

    test('advanceCursor returns null when range is completed', () {
      // Forwards: Finished Surah 114
      var cursor = const Cursor(surah: 114, ayah: 6);
      expect(QuranMeta.advanceCursor(cursor, 1, 114), isNull);

      // Backwards: Finished Surah 1
      cursor = const Cursor(surah: 1, ayah: 7);
      expect(QuranMeta.advanceCursor(cursor, 114, 1), isNull);
    });

    test('clampCursorToRange enforces valid boundaries', () {
      // Forwards range: 10 -> 114
      // Cursor at Surah 5 (outside range) should clamp to Surah 10, Ayah 1
      expect(
          QuranMeta.clampCursorToRange(
              const Cursor(surah: 5, ayah: 1), 10, 114),
          const Cursor(surah: 10, ayah: 1));

      // Cursor at Surah 15 (inside range) should remain unchanged
      expect(
          QuranMeta.clampCursorToRange(
              const Cursor(surah: 15, ayah: 5), 10, 114),
          const Cursor(surah: 15, ayah: 5));
    });
  });
}
