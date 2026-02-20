import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../../firebase_options.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/storage/hive_service.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Init Local Storage first
    await HiveService.instance.init();

    // 2. Init Firebase safely
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // If Firebase fails (e.g., offline on first run), we still proceed.
      // The Auth data source will handle offline exceptions later.
      debugPrint('Firebase init warning: $e');
    }

    if (!mounted) return;

    // 3. Hand off to the AuthGate, not DevHome directly
    Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Booting ThikrSpace...')),
    );
  }
}
