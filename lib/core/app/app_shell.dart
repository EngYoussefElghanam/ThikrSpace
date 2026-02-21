import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Your existing auth imports...
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/onboarding/presentation/pages/boot_page.dart';
import '../../features/beta_gate/presentation/pages/dev_home_page.dart';
import '../routing/app_routes.dart';

// Add the new theme imports:
import '../theme/app_theme.dart';
import '../theme/theme_repository.dart';
import '../theme/theme_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) {
            final authDataSource = FirebaseAuthDataSource();
            final authRepository = AuthRepositoryImpl(authDataSource);
            return AuthCubit(authRepository);
          },
        ),
        // 1. Inject the ThemeCubit globally
        BlocProvider<ThemeCubit>(
          create: (context) {
            final themeRepository = ThemeRepositoryImpl();
            return ThemeCubit(themeRepository);
          },
        ),
      ],
      // 2. Wrap MaterialApp in a BlocBuilder listening to ThemeCubit
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentThemeMode) {
          return MaterialApp(
            title: 'ThikrSpace',
            debugShowCheckedModeBanner: false,

            // 3. Wire up the tokens we created earlier!
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentThemeMode,

            initialRoute: AppRoutes.boot,
            routes: {
              AppRoutes.boot: (_) => const BootPage(),
              AppRoutes.authGate: (_) => const AuthGate(),
              AppRoutes.devHome: (_) => const DevHomePage(),
            },
          );
        },
      ),
    );
  }
}
