import '../entities/queue_entities.dart';

abstract class SettingsRepository {
  /// Fetches the user's queue configurations (e.g., dailyNew, dailyMaxReviews).
  Future<QueueSettings> getQueueSettings();

  /// Updates the user's queue configurations locally.
  Future<void> saveQueueSettings(QueueSettings settings);
}
