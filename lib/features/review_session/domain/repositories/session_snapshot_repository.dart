import '../entities/session_snapshot.dart';

abstract class SessionSnapshotRepository {
  Future<SessionSnapshot?> getSnapshot(String dayKey);
  Future<void> saveSnapshot(SessionSnapshot snapshot);
  Future<void> clearSnapshot(String dayKey);
}
