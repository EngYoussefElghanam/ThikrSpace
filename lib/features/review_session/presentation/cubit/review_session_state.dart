part of 'review_session_cubit.dart';

sealed class ReviewSessionState {
  const ReviewSessionState();
}

class ReviewSessionInitial extends ReviewSessionState {}

class ReviewSessionActive extends ReviewSessionState {
  final String dayKey;
  final List<AyahRef> queue;
  final int currentIndex;
  final int completedAyahsCount;
  final int defaultChunkSize;
  final ReviewChunk currentChunk;
  final bool isSubmitting;

  const ReviewSessionActive({
    required this.dayKey,
    required this.queue,
    required this.currentIndex,
    required this.completedAyahsCount,
    required this.defaultChunkSize,
    required this.currentChunk,
    this.isSubmitting = false,
  });

  int get totalAyahs => queue.length;

  ReviewSessionActive copyWith({
    int? currentIndex,
    int? completedAyahsCount,
    ReviewChunk? currentChunk,
    bool? isSubmitting,
  }) {
    return ReviewSessionActive(
      dayKey: dayKey,
      queue: queue,
      currentIndex: currentIndex ?? this.currentIndex,
      completedAyahsCount: completedAyahsCount ?? this.completedAyahsCount,
      defaultChunkSize: defaultChunkSize,
      currentChunk: currentChunk ?? this.currentChunk,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewSessionCompleted extends ReviewSessionState {
  final String dayKey;
  final int totalAyahs;

  const ReviewSessionCompleted({required this.dayKey, required this.totalAyahs});
}

class ReviewSessionError extends ReviewSessionState {
  final String message;

  const ReviewSessionError(this.message);
}
