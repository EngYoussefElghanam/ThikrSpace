import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/time_provider.dart';
import '../../domain/entities/queue_entities.dart';
import '../../domain/usecases/generate_today_queue.dart';
import '../../domain/repositories/review_repository.dart';
// Note: You'll need this interface to fetch user settings
import '../../domain/repositories/settings_repository.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  final GenerateTodayQueue generateQueue;
  final ReviewRepository reviewRepository;
  final SettingsRepository settingsRepository;
  final TimeProvider timeProvider;

  TodayCubit({
    required this.generateQueue,
    required this.reviewRepository,
    required this.settingsRepository,
    required this.timeProvider,
  }) : super(TodayInitial());

  Future<void> loadTodayQueue() async {
    emit(TodayLoading());

    try {
      // 1. Fetch REAL data from local repositories
      final settings = await settingsRepository.getQueueSettings();
      final introducedItems = await reviewRepository.getIntroducedItems();

      // If the user is brand new, cursor might be null. Default to Surah 114, Ayah 1 (or whatever default you prefer).
      final currentCursor = await reviewRepository.getCurrentCursor() ??
          const Cursor(surah: 114, ayah: 1);

      // 2. Setup the precise DayWindow for today using the injected TimeProvider
      final nowUtc = timeProvider.nowUtc;
      final window = DayWindow(
        startUtc: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day),
        endUtc: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 23, 59, 59),
      );

      // 3. Generate the Queue deterministically
      final result = generateQueue(
        introducedItems: introducedItems,
        settings: settings,
        currentCursor: currentCursor,
        window: window,
      );

      // 4. FLATTEN THE QUEUE (Extract refs from due items, then append new items)
      final List<AyahRef> flattenedSessionQueue = [
        ...result.dueQueue.map((item) => item.ref),
        ...result.newQueue,
      ];

      // 5. Fetch actual session progress (e.g., if they killed the app mid-session today)
      final completedCount =
          await reviewRepository.getTodayCompletedCount(window.startUtc);

      // 6. Emit the success state
      emit(TodayLoaded(
        rawQueue: result,
        sessionQueue: flattenedSessionQueue,
        completedCount: completedCount,
        totalCount: flattenedSessionQueue.length,
      ));
    } catch (e) {
      emit(TodayError('Failed to load today\'s queue: $e'));
    }
  }
}
