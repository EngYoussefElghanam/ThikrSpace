import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/queue_entities.dart';
import '../../domain/entities/srs_state.dart';
import '../../domain/repositories/review_repository.dart';
import '../../../../core/storage/hive_service.dart';

class HiveReviewRepositoryImpl implements ReviewRepository {
  @override
  Future<List<ItemState>> getIntroducedItems() async {
    final box = Hive.box(BoxNames.items);
    final List<ItemState> items = [];

    // Iterate over all items in the box directly
    for (final value in box.values) {
      final map = jsonDecode(value as String) as Map<String, dynamic>;

      final refMap = map['ref'] as Map<String, dynamic>;
      final srsMap = map['srs'] as Map<String, dynamic>;

      items.add(
        ItemState(
          ref: AyahRef(surah: refMap['surah'], ayah: refMap['ayah']),
          srs: SrsState(
            ease: (srsMap['ease'] as num).toDouble(),
            intervalDays: srsMap['intervalDays'] as int,
            reps: srsMap['reps'] as int,
            lapses: srsMap['lapses'] as int,
            lastReviewedAt: DateTime.fromMillisecondsSinceEpoch(
                srsMap['lastReviewedAt'],
                isUtc: true),
            dueAt: DateTime.fromMillisecondsSinceEpoch(srsMap['dueAt'],
                isUtc: true),
          ),
        ),
      );
    }

    return items;
  }

  @override
  Future<void> saveItems(List<ItemState> items) async {
    final box = Hive.box(BoxNames.items);
    final Map<String, String> batch = {};

    for (final item in items) {
      final map = {
        'ref': {'surah': item.ref.surah, 'ayah': item.ref.ayah},
        'srs': {
          'ease': item.srs.ease,
          'intervalDays': item.srs.intervalDays,
          'reps': item.srs.reps,
          'lapses': item.srs.lapses,
          'lastReviewedAt': item.srs.lastReviewedAt.millisecondsSinceEpoch,
          'dueAt': item.srs.dueAt.millisecondsSinceEpoch,
        }
      };
      batch[item.ref.id] = jsonEncode(map);
    }

    // putAll is highly optimized for bulk inserts, much faster than single puts
    await box.putAll(batch);
  }

  @override
  Future<Cursor?> getCurrentCursor() async {
    final jsonString =
        HiveService.instance.get<String>(BoxNames.appMeta, 'current_cursor');
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Cursor(surah: map['surah'], ayah: map['ayah']);
  }

  @override
  Future<void> saveCursor(Cursor cursor) async {
    final map = {'surah': cursor.surah, 'ayah': cursor.ayah};
    await HiveService.instance
        .put(BoxNames.appMeta, 'current_cursor', jsonEncode(map));
  }

  @override
  Future<int> getTodayCompletedCount(DateTime dayStartUtc) async {
    final dateKey =
        'completed_${dayStartUtc.year}-${dayStartUtc.month}-${dayStartUtc.day}';
    final countString =
        HiveService.instance.get<String>(BoxNames.appMeta, dateKey);

    if (countString == null) return 0;
    return int.tryParse(countString) ?? 0;
  }

  @override
  Future<void> saveTodayCompletedCount(DateTime dayStartUtc, int count) async {
    final dateKey =
        'completed_${dayStartUtc.year}-${dayStartUtc.month}-${dayStartUtc.day}';
    await HiveService.instance.put(BoxNames.appMeta, dateKey, count.toString());
  }
}
