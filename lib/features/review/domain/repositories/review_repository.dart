import '../entities/queue_entities.dart';

abstract class ReviewRepository {
  /// Fetches all items the user has previously reviewed/introduced.
  /// This is used by the queue generator to calculate due items.
  Future<List<ItemState>> getIntroducedItems();

  /// Saves a batch of updated item states to the local database (Hive).
  /// Called by ApplyChunkReview after the user rates a chunk.
  Future<void> saveItems(List<ItemState> items);

  /// Fetches the user's current progress cursor (the last new Ayah introduced).
  /// Returns null if the user has never started a session.
  Future<Cursor?> getCurrentCursor();

  /// Saves the user's new cursor position.
  Future<void> saveCursor(Cursor cursor);

  /// Fetches the number of Ayahs the user has successfully reviewed today.
  /// Used to populate the progress ring if the app was killed mid-session.
  Future<int> getTodayCompletedCount(DateTime dayStartUtc);

  /// (Optional but recommended) Saves the completed count to persist mid-session progress
  Future<void> saveTodayCompletedCount(DateTime dayStartUtc, int count);
}
