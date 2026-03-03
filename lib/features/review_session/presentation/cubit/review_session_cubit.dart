import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/time_provider.dart';
import '../../../review/domain/entities/queue_entities.dart';
import '../../../review/domain/repositories/review_repository.dart';
import '../../domain/entities/review_chunk.dart';
import '../../domain/entities/session_snapshot.dart';
import '../../domain/repositories/session_snapshot_repository.dart';
import '../../domain/usecases/apply_chunk_review.dart';
import '../../domain/usecases/derive_review_chunk.dart';

part 'review_session_state.dart';

class ReviewSessionCubit extends Cubit<ReviewSessionState> {
  final DeriveReviewChunk deriveReviewChunk;
  final ApplyChunkReview applyChunkReview;
  final SessionSnapshotRepository snapshotRepository;
  final ReviewRepository reviewRepository;
  final TimeProvider timeProvider;

  ReviewSessionCubit({
    required this.deriveReviewChunk,
    required this.applyChunkReview,
    required this.snapshotRepository,
    required this.reviewRepository,
    required this.timeProvider,
  }) : super(ReviewSessionInitial());

  Future<void> start({
    required String dayKey,
    required List<AyahRef> queue,
    SessionSnapshot? snapshot,
    int defaultChunkSize = 5,
  }) async {
    if (queue.isEmpty) {
      emit(ReviewSessionCompleted(dayKey: dayKey, totalAyahs: 0));
      return;
    }

    final activeSnapshot = snapshot ??
        SessionSnapshot(
          dayKey: dayKey,
          queue: queue,
          currentIndex: 0,
          completedAyahsCount: 0,
          defaultChunkSize: defaultChunkSize,
        );

    final chunk = deriveReviewChunk(
      sessionQueue: activeSnapshot.queue,
      currentIndex: activeSnapshot.currentIndex,
      defaultChunkSize: activeSnapshot.defaultChunkSize,
    );

    emit(
      ReviewSessionActive(
        dayKey: activeSnapshot.dayKey,
        queue: activeSnapshot.queue,
        currentIndex: activeSnapshot.currentIndex,
        completedAyahsCount: activeSnapshot.completedAyahsCount,
        defaultChunkSize: activeSnapshot.defaultChunkSize,
        currentChunk: chunk,
      ),
    );
  }

  void extendChunk(int endIndex) {
    final current = state;
    if (current is! ReviewSessionActive) {
      return;
    }

    final chunk = deriveReviewChunk(
      sessionQueue: current.queue,
      currentIndex: current.currentIndex,
      defaultChunkSize: current.defaultChunkSize,
      extendToIndex: endIndex,
    );

    emit(current.copyWith(currentChunk: chunk));
  }

  Future<void> submitChunk({
    required int chunkRating,
    required Map<int, int> perAyahOverrides,
  }) async {
    final current = state;
    if (current is! ReviewSessionActive) {
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      await applyChunkReview(
        chunkStartAyahRef: current.currentChunk.startRef,
        chunkEndAyahRef: current.currentChunk.endRef,
        chunkRating: chunkRating,
        overrides: perAyahOverrides,
      );

      final nextIndex = current.currentChunk.endIndex + 1;
      final nextCompleted = current.completedAyahsCount + current.currentChunk.length;
      final dayStartUtc = DateTime.utc(
        timeProvider.nowUtc.year,
        timeProvider.nowUtc.month,
        timeProvider.nowUtc.day,
      );
      await reviewRepository.saveTodayCompletedCount(dayStartUtc, nextCompleted);

      if (nextIndex >= current.queue.length) {
        await snapshotRepository.clearSnapshot(current.dayKey);
        emit(
          ReviewSessionCompleted(
            dayKey: current.dayKey,
            totalAyahs: current.queue.length,
          ),
        );
        return;
      }

      final snapshot = SessionSnapshot(
        dayKey: current.dayKey,
        queue: current.queue,
        currentIndex: nextIndex,
        completedAyahsCount: nextCompleted,
        defaultChunkSize: current.defaultChunkSize,
      );
      await snapshotRepository.saveSnapshot(snapshot);

      final nextChunk = deriveReviewChunk(
        sessionQueue: current.queue,
        currentIndex: nextIndex,
        defaultChunkSize: current.defaultChunkSize,
      );

      emit(
        current.copyWith(
          currentIndex: nextIndex,
          completedAyahsCount: nextCompleted,
          currentChunk: nextChunk,
          isSubmitting: false,
        ),
      );
    } catch (e) {
      emit(ReviewSessionError('Failed to submit chunk: $e'));
    }
  }
}
