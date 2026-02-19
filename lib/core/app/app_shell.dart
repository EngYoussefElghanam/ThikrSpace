import 'package:flutter/material.dart';
import '../routing/app_routes.dart';
import '../../features/onboarding/presentation/pages/boot_page.dart';
import '../../features/beta_gate/presentation/pages/dev_home_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThikrSpace',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.boot,
      routes: {
        AppRoutes.boot: (_) => const BootPage(),
        AppRoutes.devHome: (_) => const DevHomePage(),
      },
    );
  }
}
