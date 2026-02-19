import 'package:hive_flutter/hive_flutter.dart';

class BoxNames {
  static const String userProfile = 'user_profile';
  static const String items = 'items';
  static const String outbox = 'outbox';
  static const String appMeta = 'app_meta';
}

class HiveService {
  HiveService._(); // Private constructor to prevent instantiation
  static final HiveService instance = HiveService._();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters here later (e.g., Hive.registerAdapter(UserAdapter()))

    await Future.wait([
      Hive.openBox(BoxNames.userProfile),
      Hive.openBox(BoxNames.items),
      Hive.openBox(BoxNames.outbox),
      Hive.openBox(BoxNames.appMeta),
    ]);

    _isInitialized = true;
  }

  // Generic gateway method to safely get data
  T? get<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) as T?;
  }

  // Generic gateway method to safely put data
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  Future<void> closeAll() async {
    await Hive.close();
  }
}
