import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/utils/time_provider.dart';
import 'package:thikrspace_beta/features/review/domain/entities/queue_entities.dart';
import 'package:thikrspace_beta/features/review/domain/entities/srs_state.dart';
import 'package:thikrspace_beta/features/review/domain/repositories/review_repository.dart';
import 'package:thikrspace_beta/features/review/domain/repositories/settings_repository.dart';
import 'package:thikrspace_beta/features/review/domain/services/srs_engine.dart';
import 'package:thikrspace_beta/features/review_session/domain/usecases/apply_chunk_review.dart';

void main() {
  group('ApplyChunkReview', () {
    final fixedNow = DateTime.utc(2025, 1, 1, 12, 0, 0);

    test('applies chunk rating and per-ayah overrides', () async {
      final reviewRepo = _FakeReviewRepository(
        introducedItems: [
          ItemState(
            ref: const AyahRef(surah: 2, ayah: 1),
            srs: SrsState(
              ease: 2.5,
              intervalDays: 1,
              reps: 1,
              lapses: 0,
              lastReviewedAt: fixedNow.subtract(const Duration(days: 1)),
              dueAt: fixedNow,
            ),
          ),
        ],
        cursor: const Cursor(surah: 2, ayah: 2),
      );
      final settingsRepo = _FakeSettingsRepository();
      final usecase = ApplyChunkReview(
        reviewRepository: reviewRepo,
        settingsRepository: settingsRepo,
        srsEngine: SrsEngine(FixedTimeProvider(fixedNow)),
      );

      await usecase(
        chunkStartAyahRef: const AyahRef(surah: 2, ayah: 1),
        chunkEndAyahRef: const AyahRef(surah: 2, ayah: 2),
        chunkRating: 4,
        overrides: {2: 2},
      );

      expect(reviewRepo.savedItems.length, 2);
      expect(reviewRepo.savedItems.first.ref.ayah, 1);
      expect(reviewRepo.savedItems.first.srs.reps, 2);
      expect(reviewRepo.savedItems.last.ref.ayah, 2);
      expect(reviewRepo.savedItems.last.srs.lapses, 1);
    });

    test('creates new item and advances cursor only when introduced', () async {
      final reviewRepo = _FakeReviewRepository(
        introducedItems: [],
        cursor: const Cursor(surah: 1, ayah: 1),
      );
      final settingsRepo = _FakeSettingsRepository();
      final usecase = ApplyChunkReview(
        reviewRepository: reviewRepo,
        settingsRepository: settingsRepo,
        srsEngine: SrsEngine(FixedTimeProvider(fixedNow)),
      );

      await usecase(
        chunkStartAyahRef: const AyahRef(surah: 1, ayah: 1),
        chunkEndAyahRef: const AyahRef(surah: 1, ayah: 1),
        chunkRating: 5,
        overrides: const {},
      );

      expect(reviewRepo.savedItems.single.ref, const AyahRef(surah: 1, ayah: 1));
      expect(reviewRepo.savedCursor, const Cursor(surah: 1, ayah: 2));
    });
  });
}

class _FakeReviewRepository implements ReviewRepository {
  final List<ItemState> introducedItems;
  final Cursor? cursor;
  final List<ItemState> savedItems = [];
  Cursor? savedCursor;

  _FakeReviewRepository({required this.introducedItems, required this.cursor});

  @override
  Future<Cursor?> getCurrentCursor() async => cursor;

  @override
  Future<List<ItemState>> getIntroducedItems() async => introducedItems;

  @override
  Future<int> getTodayCompletedCount(DateTime dayStartUtc) async => 0;

  @override
  Future<void> saveCursor(Cursor cursor) async {
    savedCursor = cursor;
  }

  @override
  Future<void> saveItems(List<ItemState> items) async {
    savedItems
      ..clear()
      ..addAll(items);
  }

  @override
  Future<void> saveTodayCompletedCount(DateTime dayStartUtc, int count) async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<QueueSettings> getQueueSettings() async => const QueueSettings(
        dailyNew: 5,
        dailyMaxReviews: 20,
        rangeStartSurah: 1,
        rangeEndSurah: 114,
      );

  @override
  Future<void> saveQueueSettings(QueueSettings settings) async {}
}
