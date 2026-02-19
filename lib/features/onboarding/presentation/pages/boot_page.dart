import 'package:flutter/material.dart';
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
    await HiveService.instance.init();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.devHome);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Booting ThikrSpace...')),
    );
  }
}
