# Cost Control & Architecture Rules

1. **No Real-Time Listeners (`.snapshots()`) in UI.**
   * The UI must ONLY listen to the local Hive database via Cubit Streams. 
   * Firebase is strictly a background synchronization target.
2. **Lazy Item Creation.**
   * Never loop from 1 to 6236 and `set()` documents. Calculate new items locally via the cursor, and write them to Firestore *only* when the user completes their daily session.
3. **Delta Syncs Only.**
   * When pulling from Firestore, always use `.where('updatedAt', isGreaterThan: lastSyncAt)`. Never pull the entire `/items` collection on every app launch.
4. **Batch Writes.**
   * Use `WriteBatch` to push the user's daily reviews all at once when they finish a session, minimizing individual network handshakes.