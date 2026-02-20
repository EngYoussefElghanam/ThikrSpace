import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/utils/id_generator.dart';
import 'package:thikrspace_beta/core/utils/validators.dart';

void main() {
  group('IdGenerator Tests', () {
    test('generateItemId outputs correct deterministic format', () {
      final id =
          IdGenerator.generateItemId(surah: 2, ayah: 255); // Ayat al-Kursi
      expect(id, 's2_a255');

      final id2 = IdGenerator.generateItemId(surah: 114, ayah: 6);
      expect(id2, 's114_a6');
    });
  });

  group('Validators Tests', () {
    test('isWithinRange returns true when inside boundaries', () {
      final result = Validators.isWithinRange(5, min: 1, max: 10);
      expect(result, isTrue);
    });

    test('isWithinRange returns false when outside boundaries', () {
      final tooLow = Validators.isWithinRange(0, min: 1, max: 10);
      expect(tooLow, isFalse);

      final tooHigh = Validators.isWithinRange(11, min: 1, max: 10);
      expect(tooHigh, isFalse);
    });

    test('isWithinRange handles edge cases exactly on the boundary', () {
      expect(Validators.isWithinRange(1, min: 1, max: 10), isTrue);
      expect(Validators.isWithinRange(10, min: 1, max: 10), isTrue);
    });
  });
}
