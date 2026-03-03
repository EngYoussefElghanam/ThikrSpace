import '../../../../core/constants/quran-meta.dart';
import '../../../review/domain/entities/queue_entities.dart';
import '../../../review/domain/repositories/review_repository.dart';
import '../../../review/domain/repositories/settings_repository.dart';
import '../../../review/domain/services/srs_engine.dart';

class ApplyChunkReview {
  final ReviewRepository reviewRepository;
  final SettingsRepository settingsRepository;
  final SrsEngine srsEngine;

  ApplyChunkReview({
    required this.reviewRepository,
    required this.settingsRepository,
    required this.srsEngine,
  });

  Future<List<ItemState>> call({
    required AyahRef chunkStartAyahRef,
    required AyahRef chunkEndAyahRef,
    required int chunkRating,
    required Map<int, int> overrides,
  }) async {
    if (chunkStartAyahRef.surah != chunkEndAyahRef.surah) {
      throw ArgumentError('Chunk must stay inside one surah');
    }

    final introduced = await reviewRepository.getIntroducedItems();
    final introducedById = {for (final item in introduced) item.ref.id: item};

    final updatedItems = <ItemState>[];
    var introducedNewCount = 0;

    for (var ayah = chunkStartAyahRef.ayah; ayah <= chunkEndAyahRef.ayah; ayah++) {
      final ref = AyahRef(surah: chunkStartAyahRef.surah, ayah: ayah);
      final rating = overrides[ayah] ?? chunkRating;
      final current = introducedById[ref.id];

      final nextSrs = srsEngine.calculateNextState(
        current: current?.srs,
        rating: rating,
      );
      final nextState = ItemState(ref: ref, srs: nextSrs);
      updatedItems.add(nextState);

      if (current == null) {
        introducedNewCount += 1;
      }
    }

    await reviewRepository.saveItems(updatedItems);
    await _advanceCursorForIntroductions(introducedNewCount);

    return updatedItems;
  }

  Future<void> _advanceCursorForIntroductions(int introducedNewCount) async {
    if (introducedNewCount == 0) {
      return;
    }

    final settings = await settingsRepository.getQueueSettings();
    var cursor = await reviewRepository.getCurrentCursor() ??
        Cursor(surah: settings.rangeStartSurah, ayah: 1);

    for (var i = 0; i < introducedNewCount; i++) {
      final next = QuranMeta.advanceCursor(
        cursor,
        settings.rangeStartSurah,
        settings.rangeEndSurah,
      );
      if (next == null) {
        break;
      }
      cursor = next;
    }

    await reviewRepository.saveCursor(cursor);
  }
}
