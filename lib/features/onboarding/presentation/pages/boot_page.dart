import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../firebase_options.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';

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

    context.read<ThemeCubit>().loadTheme();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init warning: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
  }

  @override
  Widget build(BuildContext context) {
    // AppScaffold provides the safe area and correct background color automatically
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ThikrSpace',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const LoadingState(), // Uses your UI Kit component
          ],
        ),
      ),
    );
  }
}
