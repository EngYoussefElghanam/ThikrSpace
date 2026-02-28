import '../../../../core/constants/quran-meta.dart';
import 'srs_state.dart'; // From Day 7

class AyahRef {
  final int surah;
  final int ayah;
  String get id => 's${surah}_a$ayah';
  const AyahRef({required this.surah, required this.ayah});
}

class ItemState {
  final AyahRef ref;
  final SrsState srs;
  const ItemState({required this.ref, required this.srs});
}

class QueueSettings {
  final int dailyNew;
  final int dailyMaxReviews;
  final int rangeStartSurah;
  final int rangeEndSurah;
  const QueueSettings(
      {required this.dailyNew,
      required this.dailyMaxReviews,
      required this.rangeStartSurah,
      required this.rangeEndSurah});
}

class DayWindow {
  final DateTime startUtc;
  final DateTime endUtc;
  const DayWindow({required this.startUtc, required this.endUtc});
}

class TodayQueueResult {
  final List<ItemState> dueQueue;
  final List<AyahRef> newQueue;
  final Cursor? nextCursor; // Null if range is fully complete
  const TodayQueueResult(
      {required this.dueQueue, required this.newQueue, this.nextCursor});
}
