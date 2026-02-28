import '../../../../core/constants/quran-meta.dart';
import '../entities/queue_entities.dart';

class GenerateTodayQueue {
  TodayQueueResult call({
    required List<ItemState> introducedItems,
    required QueueSettings settings,
    required Cursor currentCursor,
    required DayWindow window,
  }) {
    // 1. Filter & Sort Due Items (Stable Ordering: Surah ASC, Ayah ASC)
    List<ItemState> dueItems = introducedItems.where((item) {
      // Due if the dueAt timestamp is exactly equal to or before the end of our current day window
      return item.srs.dueAt.isBefore(window.endUtc) ||
          item.srs.dueAt.isAtSameMomentAs(window.endUtc);
    }).toList();

    dueItems.sort((a, b) {
      int surahComp = a.ref.surah.compareTo(b.ref.surah);
      if (surahComp != 0) return surahComp;
      return a.ref.ayah.compareTo(b.ref.ayah);
    });

    // Enforce max reviews cap
    if (dueItems.length > settings.dailyMaxReviews) {
      dueItems = dueItems.sublist(0, settings.dailyMaxReviews);
    }

    // 2. Generate New Items
    List<AyahRef> newItems = [];
    Set<String> existingIds = introducedItems.map((i) => i.ref.id).toSet();

    // Ensure cursor is strictly within the user's current settings range before we start
    Cursor? activeCursor = QuranMeta.clampCursorToRange(
        currentCursor, settings.rangeStartSurah, settings.rangeEndSurah);

    while (newItems.length < settings.dailyNew && activeCursor != null) {
      String candidateId = 's${activeCursor.surah}_a${activeCursor.ayah}';

      // Prevent duplicates: Only add if we haven't already introduced it
      if (!existingIds.contains(candidateId)) {
        newItems
            .add(AyahRef(surah: activeCursor.surah, ayah: activeCursor.ayah));

        // 🚨 FIX: Immediately add it to the set so we NEVER add it again!
        existingIds.add(candidateId);
      }

      // Advance cursor
      activeCursor = QuranMeta.advanceCursor(
          activeCursor, settings.rangeStartSurah, settings.rangeEndSurah);
    }

    return TodayQueueResult(
      dueQueue: dueItems,
      newQueue: newItems,
      nextCursor: activeCursor,
    );
  }
}
