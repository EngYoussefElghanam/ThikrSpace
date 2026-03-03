import 'dart:convert';

import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/session_snapshot.dart';
import '../../domain/repositories/session_snapshot_repository.dart';

class HiveSessionSnapshotRepository implements SessionSnapshotRepository {
  static const _snapshotPrefix = 'review_snapshot_';

  String _keyForDay(String dayKey) => '$_snapshotPrefix$dayKey';

  @override
  Future<void> clearSnapshot(String dayKey) async {
    await HiveService.instance.put(BoxNames.appMeta, _keyForDay(dayKey), '');
  }

  @override
  Future<SessionSnapshot?> getSnapshot(String dayKey) async {
    final raw =
        HiveService.instance.get<String>(BoxNames.appMeta, _keyForDay(dayKey));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return SessionSnapshot.fromMap(map);
  }

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {
    await HiveService.instance.put(
      BoxNames.appMeta,
      _keyForDay(snapshot.dayKey),
      jsonEncode(snapshot.toMap()),
    );
  }
}
