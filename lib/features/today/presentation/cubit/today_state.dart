part of 'today_cubit.dart';

sealed class TodayState {}

class TodayInitial extends TodayState {}

class TodayLoading extends TodayState {}

class TodayLoaded extends TodayState {
  final String dayKey;
  final TodayQueueResult rawQueue;
  final List<AyahRef> sessionQueue;
  final List<AyahRef> overflowDueQueue;
  final int completedCount;
  final int totalCount;
  final bool hasSnapshot;
  final SessionSnapshot? snapshot;

  TodayLoaded({
    required this.dayKey,
    required this.rawQueue,
    required this.sessionQueue,
    required this.overflowDueQueue,
    required this.completedCount,
    required this.totalCount,
    required this.hasSnapshot,
    required this.snapshot,
  });

  int get dueCount => rawQueue.dueQueue.length;
  int get newCount => rawQueue.newQueue.length;
  bool get isCompleted => totalCount > 0 && completedCount >= totalCount;
  bool get hasOverflowDue => overflowDueQueue.isNotEmpty;
}

class TodayError extends TodayState {
  final String message;

  TodayError(this.message);
}
