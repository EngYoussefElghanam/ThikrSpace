import '../../../review/domain/entities/queue_entities.dart';

class ReviewChunk {
  final int startIndex;
  final int endIndex;
  final AyahRef startRef;
  final AyahRef endRef;
  final List<AyahRef> ayahs;

  const ReviewChunk({
    required this.startIndex,
    required this.endIndex,
    required this.startRef,
    required this.endRef,
    required this.ayahs,
  });

  int get length => ayahs.length;
}
