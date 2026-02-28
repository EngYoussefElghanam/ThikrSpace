import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/features/review/domain/entities/queue_entities.dart';
import 'package:thikrspace_beta/features/review/domain/entities/srs_state.dart';
import 'package:thikrspace_beta/features/review/domain/usecases/generate_today_queue.dart';

void main() {
  group('Day 8 - TodayQueue & Cursor Pure Tests', () {
    final usecase = GenerateTodayQueue();
    final fixedNow = DateTime.utc(2026, 2, 28);
    final dayWindow = DayWindow(
        startUtc: fixedNow,
        endUtc: fixedNow.add(const Duration(hours: 23, minutes: 59)));

    SrsState createMockSrs({required int dueDaysAgo}) {
      return SrsState(
        ease: 2.5,
        intervalDays: 1,
        reps: 1,
        lapses: 0,
        lastReviewedAt: fixedNow.subtract(Duration(days: dueDaysAgo + 1)),
        dueAt: fixedNow.subtract(Duration(days: dueDaysAgo)),
      );
    }

    test(
        'DayWindow boundary correctness: perfectly respects endUtc inclusive edge',
        () {
      final windowEnd = DateTime.utc(2026, 2, 28, 23, 59, 59);
      final exactWindow = DayWindow(
          startUtc: DateTime.utc(2026, 2, 28, 0, 0, 0), endUtc: windowEnd);

      // We instantiate them directly to avoid the Dart cascade operator (..) trap
      final boundarySrs = SrsState(
        ease: 2.5, intervalDays: 1, reps: 1, lapses: 0,
        lastReviewedAt: windowEnd.subtract(const Duration(days: 1)),
        dueAt: windowEnd, // Exactly on the boundary (23:59:59)
      );

      final tomorrowSrs = SrsState(
        ease: 2.5, intervalDays: 1, reps: 1, lapses: 0,
        lastReviewedAt: windowEnd.subtract(const Duration(days: 1)),
        // 1 second into tomorrow (00:00:00)
        dueAt: windowEnd.add(const Duration(seconds: 1)),
      );

      final introduced = [
        ItemState(ref: const AyahRef(surah: 1, ayah: 1), srs: boundarySrs),
        ItemState(ref: const AyahRef(surah: 1, ayah: 2), srs: tomorrowSrs),
      ];

      final result = usecase(
        introducedItems: introduced,
        settings: const QueueSettings(
            dailyNew: 0,
            dailyMaxReviews: 50,
            rangeStartSurah: 1,
            rangeEndSurah: 114),
        currentCursor: const Cursor(surah: 2, ayah: 1),
        window: exactWindow,
      );

      // Now it will correctly only count the first one!
      expect(result.dueQueue.length, 1);
      expect(result.dueQueue.first.ref.id, 's1_a1');
    });
    test('Generates new items forwards and crosses boundaries (1 -> 2)', () {
      final result = usecase(
        introducedItems: [],
        settings: const QueueSettings(
            dailyNew: 3,
            dailyMaxReviews: 50,
            rangeStartSurah: 1,
            rangeEndSurah: 114), // FORWARDS RANGE
        currentCursor: const Cursor(surah: 1, ayah: 6),
        window: dayWindow,
      );

      // Surah 1 has 7 ayahs. Asking for 3 items starting at 1:6 should yield: 1:6, 1:7, 2:1
      expect(result.newQueue.length, 3);
      expect(result.newQueue[0].id, 's1_a6');
      expect(result.newQueue[1].id, 's1_a7');
      expect(result.newQueue[2].id, 's2_a1');

      // Cursor should rest on the next ayah
      expect(result.nextCursor, const Cursor(surah: 2, ayah: 2));
    });

    test('Determinism: Identical inputs produce identical outputs', () {
      final settings = const QueueSettings(
          dailyNew: 5,
          dailyMaxReviews: 10,
          rangeStartSurah: 114,
          rangeEndSurah: 1);
      final cursor = const Cursor(surah: 114, ayah: 1);

      // Run the exact same usecase twice
      final run1 = usecase(
          introducedItems: [],
          settings: settings,
          currentCursor: cursor,
          window: dayWindow);
      final run2 = usecase(
          introducedItems: [],
          settings: settings,
          currentCursor: cursor,
          window: dayWindow);

      // The exact IDs generated must match perfectly
      expect(run1.newQueue.map((e) => e.id).toList(),
          run2.newQueue.map((e) => e.id).toList());
      expect(run1.nextCursor, run2.nextCursor);
    });

    test('Respects dailyMaxReviews cap and stable ordering', () {
      final introduced = [
        ItemState(
            ref: const AyahRef(surah: 2, ayah: 5),
            srs: createMockSrs(dueDaysAgo: 1)),
        ItemState(
            ref: const AyahRef(surah: 2, ayah: 1),
            srs: createMockSrs(dueDaysAgo: 2)), // Should sort first
        ItemState(
            ref: const AyahRef(surah: 3, ayah: 1),
            srs: createMockSrs(dueDaysAgo: 1)),
      ];

      final result = usecase(
        introducedItems: introduced,
        settings: const QueueSettings(
            dailyNew: 0,
            dailyMaxReviews: 2,
            rangeStartSurah: 114,
            rangeEndSurah: 1),
        currentCursor: const Cursor(surah: 114, ayah: 1),
        window: dayWindow,
      );

      expect(result.dueQueue.length, 2); // Capped at 2
      expect(result.dueQueue.first.ref.id, 's2_a1'); // Sorted correctly
      expect(result.dueQueue.last.ref.id, 's2_a5');
      expect(result.newQueue.isEmpty, true);
    });

    test('Generates new items backwards and crosses boundaries (114 -> 113)',
        () {
      final result = usecase(
        introducedItems: [],
        settings: const QueueSettings(
            dailyNew: 8,
            dailyMaxReviews: 50,
            rangeStartSurah: 114,
            rangeEndSurah: 1),
        currentCursor: const Cursor(surah: 114, ayah: 4),
        window: dayWindow,
      );

      expect(result.newQueue.length, 8);
      // Surah 114 has 6 ayahs. It should do 114:4, 114:5, 114:6, then drop to 113:1
      expect(result.newQueue[0].id, 's114_a4');
      expect(result.newQueue[2].id, 's114_a6');
      expect(result.newQueue[3].id, 's113_a1');
      expect(result.newQueue[7].id, 's113_a5');

      // Cursor should be resting on the *next* ayah to learn
// Surah 113 only has 5 ayahs, so the cursor correctly wraps to Surah 112!
      expect(result.nextCursor, const Cursor(surah: 112, ayah: 1));
    });

    test('Prevents duplicates if cursor overlaps with already introduced items',
        () {
      final introduced = [
        ItemState(
            ref: const AyahRef(surah: 1, ayah: 2),
            srs: createMockSrs(dueDaysAgo: 0)) // Already learning
      ];

      final result = usecase(
        introducedItems: introduced,
        settings: const QueueSettings(
            dailyNew: 3,
            dailyMaxReviews: 50,
            rangeStartSurah: 1,
            rangeEndSurah: 114),
        currentCursor: const Cursor(
            surah: 1, ayah: 1), // Cursor starts before the overlapping item
        window: dayWindow,
      );

      // Should skip s1_a2 and give us a1, a3, a4
      expect(result.newQueue.length, 3);
      expect(result.newQueue.map((e) => e.id).toList(),
          ['s1_a1', 's1_a3', 's1_a4']);
    });
  });
}
