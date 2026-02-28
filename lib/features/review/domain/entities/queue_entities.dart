import 'srs_state.dart';

class Cursor {
  final int surah;
  final int ayah;
  const Cursor({required this.surah, required this.ayah});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cursor && surah == other.surah && ayah == other.ayah;

  @override
  int get hashCode => surah.hashCode ^ ayah.hashCode;

  @override
  String toString() => 'Cursor(s$surah:a$ayah)';
}

class AyahRef {
  final int surah;
  final int ayah;
  String get id => 's${surah}_a$ayah';
  const AyahRef({required this.surah, required this.ayah});

  // FIX #2: Added equality and hash so Set<AyahRef> works natively later!
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahRef && surah == other.surah && ayah == other.ayah;

  @override
  int get hashCode => surah.hashCode ^ ayah.hashCode;
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
  const QueueSettings({
    required this.dailyNew,
    required this.dailyMaxReviews,
    required this.rangeStartSurah,
    required this.rangeEndSurah,
  });
}

class DayWindow {
  final DateTime startUtc;
  final DateTime endUtc; // Handled as inclusive end-of-day
  const DayWindow({required this.startUtc, required this.endUtc});
}

class TodayQueueResult {
  final List<ItemState> dueQueue;
  final List<AyahRef> newQueue;
  final Cursor? nextCursor; // Null if range is fully complete
  const TodayQueueResult({
    required this.dueQueue,
    required this.newQueue,
    this.nextCursor,
  });
}
