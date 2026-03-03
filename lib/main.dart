import 'package:flutter/material.dart';

import 'core/app/app_shell.dart';
import 'core/storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(const AppShell());
}
