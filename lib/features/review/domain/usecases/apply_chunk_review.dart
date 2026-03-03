import '../entities/queue_entities.dart';
import '../services/srs_engine.dart';
import '../repositories/review_repository.dart';

class ApplyChunkReview {
  final SrsEngine srsEngine;
  final ReviewRepository
      repository; // Strictly injected, no more lazy comments!

  ApplyChunkReview(this.srsEngine, this.repository);

  /// Takes a list of Ayahs (the chunk), the default rating, and any overrides.
  /// Calculates the new spaced repetition states and saves them to the database.
  Future<List<ItemState>> call({
    required List<ItemState?> currentStates, // Null if it's a "New" item
    required List<AyahRef> chunkRefs,
    required int defaultRating,
    required Map<String, int> overrides, // Key: AyahRef.id, Value: 1-5 rating
  }) async {
    List<ItemState> updatedItems = [];

    for (int i = 0; i < chunkRefs.length; i++) {
      final ref = chunkRefs[i];
      final currentState = currentStates[i];

      // Check if user provided an override for this specific Ayah, otherwise use default
      final int rating =
          overrides.containsKey(ref.id) ? overrides[ref.id]! : defaultRating;

      // CORRECT USAGE: Uses your exact Day 7 SrsEngine method
      // If currentState?.srs is null, the engine correctly handles it as a new item.
      final nextState = srsEngine.calculateNextState(
        current: currentState?.srs,
        rating: rating,
      );

      updatedItems.add(ItemState(ref: ref, srs: nextState));
    }

    // Actually save the progress to your database!
    await repository.saveItems(updatedItems);

    return updatedItems;
  }
}
