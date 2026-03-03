import '../../../review/domain/entities/queue_entities.dart';
import '../entities/review_chunk.dart';

class DeriveReviewChunk {
  ReviewChunk call({
    required List<AyahRef> sessionQueue,
    required int currentIndex,
    required int defaultChunkSize,
    int? extendToIndex,
  }) {
    if (sessionQueue.isEmpty) {
      throw ArgumentError('Session queue cannot be empty');
    }
    if (currentIndex < 0 || currentIndex >= sessionQueue.length) {
      throw ArgumentError('Invalid currentIndex: $currentIndex');
    }

    final runEnd = _contiguousRunEnd(sessionQueue, currentIndex);
    final desiredEnd = currentIndex + defaultChunkSize - 1;
    var endIndex = desiredEnd > runEnd ? runEnd : desiredEnd;

    if (extendToIndex != null) {
      if (extendToIndex < currentIndex || extendToIndex > runEnd) {
        throw ArgumentError('extendToIndex must be within contiguous run');
      }
      endIndex = extendToIndex;
    }

    final ayahs = sessionQueue.sublist(currentIndex, endIndex + 1);
    return ReviewChunk(
      startIndex: currentIndex,
      endIndex: endIndex,
      startRef: ayahs.first,
      endRef: ayahs.last,
      ayahs: ayahs,
    );
  }

  int _contiguousRunEnd(List<AyahRef> queue, int startIndex) {
    var endIndex = startIndex;
    for (var i = startIndex + 1; i < queue.length; i++) {
      final previous = queue[i - 1];
      final current = queue[i];
      final isConsecutiveSameSurah =
          current.surah == previous.surah && current.ayah == previous.ayah + 1;
      if (!isConsecutiveSameSurah) {
        break;
      }
      endIndex = i;
    }
    return endIndex;
  }
}
