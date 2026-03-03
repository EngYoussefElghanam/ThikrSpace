import 'dart:convert';
import '../../domain/entities/queue_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/storage/hive_service.dart';

class HiveSettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<QueueSettings> getQueueSettings() async {
    final jsonString = HiveService.instance
        .get<String>(BoxNames.userProfile, 'queue_settings');

    if (jsonString == null) {
      return const QueueSettings(
        dailyNew: 5,
        dailyMaxReviews: 20,
        rangeStartSurah: 114,
        rangeEndSurah: 1,
      );
    }

    final map = jsonDecode(jsonString) as Map<String, dynamic>;

    return QueueSettings(
      dailyNew: map['dailyNew'] as int,
      dailyMaxReviews: map['dailyMaxReviews'] as int,
      rangeStartSurah: map['rangeStartSurah'] as int,
      rangeEndSurah: map['rangeEndSurah'] as int,
    );
  }

  @override
  Future<void> saveQueueSettings(QueueSettings settings) async {
    final map = {
      'dailyNew': settings.dailyNew,
      'dailyMaxReviews': settings.dailyMaxReviews,
      'rangeStartSurah': settings.rangeStartSurah,
      'rangeEndSurah': settings.rangeEndSurah,
    };

    await HiveService.instance
        .put(BoxNames.userProfile, 'queue_settings', jsonEncode(map));
  }
}
