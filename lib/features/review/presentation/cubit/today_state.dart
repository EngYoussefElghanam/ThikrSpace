part of 'today_cubit.dart';

sealed class TodayState {}

final class TodayInitial extends TodayState {}

final class TodayLoading extends TodayState {}

final class TodayLoaded extends TodayState {
  final TodayQueueResult rawQueue;
  final List<AyahRef> sessionQueue;
  final int completedCount;
  final int totalCount;

  TodayLoaded({
    required this.rawQueue,
    required this.sessionQueue,
    required this.completedCount,
    required this.totalCount,
  });
}

final class TodayError extends TodayState {
  final String message;

  TodayError(this.message);
}
