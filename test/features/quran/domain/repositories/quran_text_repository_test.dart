import 'package:flutter_test/flutter_test.dart';
// Note: Adjust the import path based on where you put the Impl file
import 'package:thikrspace_beta/features/quran/domain/repositories/quran_text_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Day 8 - Real QuranTextRepository Tests', () {
    late QuranTextRepositoryRealImpl repository;

    setUp(() {
      repository = QuranTextRepositoryRealImpl();
    });

    test('Loads Surah Al-Fatiha correctly (001.json)', () async {
      final ayahText = await repository.getAyah(1, 1);
      // Depending on your Tanzil file, it might just be text, or have the bismillah included.
      expect(ayahText.isNotEmpty, true);
      print('Surah 1, Ayah 1: $ayahText');
    });

    test('getRange fetches multiple consecutive ayahs', () async {
      // Fetch Ayahs 1, 2, and 3 from Surah 114
      final range = await repository.getRange(114, 1, 3);

      expect(range.length, 3);
      expect(range[0].isNotEmpty, true);
      print('Surah 114:1 -> ${range[0]}');
    });

    test('Throws ArgumentError if ayah is out of bounds', () async {
      // Surah 114 only has 6 ayahs
      expect(() => repository.getAyah(114, 7), throwsA(isA<ArgumentError>()));
    });
  });
}
