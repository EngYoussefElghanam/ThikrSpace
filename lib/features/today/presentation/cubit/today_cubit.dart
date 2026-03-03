import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/time_provider.dart';
import '../../../review/domain/entities/queue_entities.dart';
import '../../../review/domain/repositories/review_repository.dart';
import '../../../review/domain/repositories/settings_repository.dart';
import '../../../review/domain/usecases/generate_today_queue.dart';
import '../../../review_session/domain/entities/session_snapshot.dart';
import '../../../review_session/domain/repositories/session_snapshot_repository.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  final GenerateTodayQueue generateQueue;
  final ReviewRepository reviewRepository;
  final SettingsRepository settingsRepository;
  final SessionSnapshotRepository snapshotRepository;
  final TimeProvider timeProvider;

  TodayCubit({
    required this.generateQueue,
    required this.reviewRepository,
    required this.settingsRepository,
    required this.snapshotRepository,
    required this.timeProvider,
  }) : super(TodayInitial());

  Future<void> loadTodayQueue() async {
    emit(TodayLoading());

    try {
      final nowUtc = timeProvider.nowUtc;
      final dayStartUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
      final dayWindow = DayWindow(
        startUtc: dayStartUtc,
        endUtc: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 23, 59, 59),
      );
      final dayKey = _dayKey(nowUtc);

      final settings = await settingsRepository.getQueueSettings();
      final introducedItems = await reviewRepository.getIntroducedItems();
      final currentCursor = await reviewRepository.getCurrentCursor() ??
          Cursor(surah: settings.rangeStartSurah, ayah: 1);

      final queue = generateQueue(
        introducedItems: introducedItems,
        settings: settings,
        currentCursor: currentCursor,
        window: dayWindow,
      );

      final sessionQueue = [
        ...queue.dueQueue.map((item) => item.ref),
        ...queue.newQueue,
      ];

      final snapshot = await snapshotRepository.getSnapshot(dayKey);
      final completedCount = snapshot?.completedAyahsCount ??
          await reviewRepository.getTodayCompletedCount(dayStartUtc);

      emit(
        TodayLoaded(
          dayKey: dayKey,
          rawQueue: queue,
          sessionQueue: snapshot?.queue ?? sessionQueue,
          completedCount: completedCount,
          totalCount: sessionQueue.length,
          hasSnapshot: snapshot != null && !snapshot.isComplete,
          snapshot: snapshot,
        ),
      );
    } catch (e) {
      emit(TodayError('Failed to load today queue: $e'));
    }
  }

  String _dayKey(DateTime nowUtc) {
    final month = nowUtc.month.toString().padLeft(2, '0');
    final day = nowUtc.day.toString().padLeft(2, '0');
    return '${nowUtc.year}-$month-$day';
  }
}
