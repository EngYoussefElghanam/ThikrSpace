import '../../../review/domain/entities/queue_entities.dart';

class SessionSnapshot {
  final String dayKey;
  final List<AyahRef> queue;
  final int currentIndex;
  final int completedAyahsCount;
  final int defaultChunkSize;

  const SessionSnapshot({
    required this.dayKey,
    required this.queue,
    required this.currentIndex,
    required this.completedAyahsCount,
    this.defaultChunkSize = 5,
  });

  bool get isComplete => currentIndex >= queue.length;

  Map<String, dynamic> toMap() => {
        'dayKey': dayKey,
        'queue': queue
            .map((ref) => {'surah': ref.surah, 'ayah': ref.ayah})
            .toList(growable: false),
        'currentIndex': currentIndex,
        'completedAyahsCount': completedAyahsCount,
        'defaultChunkSize': defaultChunkSize,
      };

  factory SessionSnapshot.fromMap(Map<String, dynamic> map) {
    final queue = (map['queue'] as List<dynamic>)
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => AyahRef(
            surah: item['surah'] as int,
            ayah: item['ayah'] as int,
          ),
        )
        .toList(growable: false);

    return SessionSnapshot(
      dayKey: map['dayKey'] as String,
      queue: queue,
      currentIndex: map['currentIndex'] as int,
      completedAyahsCount: map['completedAyahsCount'] as int,
      defaultChunkSize: (map['defaultChunkSize'] as int?) ?? 5,
    );
  }
}
