import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/features/review/domain/entities/queue_entities.dart';
import 'package:thikrspace_beta/features/review_session/domain/usecases/derive_review_chunk.dart';

void main() {
  group('DeriveReviewChunk', () {
    final usecase = DeriveReviewChunk();

    test('uses default chunk size within contiguous run', () {
      final queue = List.generate(
        8,
        (index) => AyahRef(surah: 2, ayah: index + 1),
      );

      final chunk = usecase(
        sessionQueue: queue,
        currentIndex: 0,
        defaultChunkSize: 5,
      );

      expect(chunk.startRef.ayah, 1);
      expect(chunk.endRef.ayah, 5);
      expect(chunk.length, 5);
    });

    test('stops at surah boundary or non-consecutive ayah', () {
      final queue = [
        const AyahRef(surah: 2, ayah: 10),
        const AyahRef(surah: 2, ayah: 11),
        const AyahRef(surah: 2, ayah: 13),
        const AyahRef(surah: 3, ayah: 1),
      ];

      final chunk = usecase(
        sessionQueue: queue,
        currentIndex: 0,
        defaultChunkSize: 5,
      );

      expect(chunk.startRef.ayah, 10);
      expect(chunk.endRef.ayah, 11);
      expect(chunk.length, 2);
    });

    test('supports extending chunk end inside contiguous run', () {
      final queue = List.generate(
        7,
        (index) => AyahRef(surah: 5, ayah: index + 1),
      );

      final chunk = usecase(
        sessionQueue: queue,
        currentIndex: 0,
        defaultChunkSize: 3,
        extendToIndex: 5,
      );

      expect(chunk.endRef.ayah, 6);
      expect(chunk.length, 6);
    });
  });
}
