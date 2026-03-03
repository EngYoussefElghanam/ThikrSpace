import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thikrspace_beta/features/auth/presentation/pages/sign_up_page.dart';
import 'package:thikrspace_beta/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:thikrspace_beta/features/review/presentation/cubit/today_cubit.dart';
import 'package:thikrspace_beta/features/review/presentation/pages/today_page.dart';
import '../../features/access_gate/presentation/cubit/access_gate_cubit.dart';

// Your existing auth imports...
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/onboarding/presentation/pages/boot_page.dart';
import '../../features/access_gate/presentation/pages/dev_home_page.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/review/domain/usecases/generate_today_queue.dart';
import '../routing/app_routes.dart';

// Add the new theme imports:
import '../theme/app_theme.dart';
import '../theme/theme_repository.dart';
import '../theme/theme_cubit.dart';
import '../utils/time_provider.dart';

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
        BlocProvider<OnboardingCubit>(
          create: (context) {
            // Re-use the repository we created for BetaGate
            return OnboardingCubit(UserProfileRepositoryImpl());
          },
        ),

        BlocProvider(
          create: (context) {
            // Instantiate your dependencies here.
            // Note: If you use a service locator like `get_it`, you would do:
            // return sl<TodayCubit>()..loadTodayQueue();

            return TodayCubit(
              generateQueue: GenerateTodayQueue(),

              // Assuming you provide these repositories higher up in your app via MultiRepositoryProvider
              // Otherwise, instantiate your HiveImpls right here!
              reviewRepository: context.read(),
              settingsRepository: context.read(),
              timeProvider: SystemTimeProvider(),
            )..loadTodayQueue(); // 🚨 Fire the load event immediately when the Cubit is created
          },
        ),
        BlocProvider<AccessGateCubit>(
          create: (context) {
            // Instantiate the offline-first repo
            final profileRepo = UserProfileRepositoryImpl(
              firestore: FirebaseFirestore.instance,
            );
            return AccessGateCubit(profileRepo);
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
              AppRoutes.devHome: (_) => const TodayPage(),
              AppRoutes.onBoarding: (_) => const OnboardingPage(),
              AppRoutes.signUp: (_) => const SignUpPage(),
            },
          );
        },
      ),
    );
  }
}
