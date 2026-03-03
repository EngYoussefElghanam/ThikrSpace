import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/access_gate/presentation/cubit/access_gate_cubit.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/onboarding/presentation/pages/boot_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_text_repository.dart';
import '../../features/quran/domain/repositories/quran_text_repository_impl.dart';
import '../../features/review/data/repositories/hive_settings_repository_impl.dart';
import '../../features/review/data/repositories/review_repository_impl.dart';
import '../../features/review/domain/repositories/review_repository.dart';
import '../../features/review/domain/repositories/settings_repository.dart';
import '../../features/review/domain/services/srs_engine.dart';
import '../../features/review/domain/usecases/generate_today_queue.dart';
import '../../features/review_session/data/repositories/hive_session_snapshot_repository.dart';
import '../../features/review_session/domain/repositories/session_snapshot_repository.dart';
import '../../features/today/presentation/cubit/today_cubit.dart';
import '../../features/today/presentation/pages/today_page.dart';
import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import '../theme/theme_cubit.dart';
import '../theme/theme_repository.dart';
import '../utils/time_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final timeProvider = SystemTimeProvider();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ReviewRepository>(
          create: (_) => HiveReviewRepositoryImpl(),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => HiveSettingsRepositoryImpl(),
        ),
        RepositoryProvider<SessionSnapshotRepository>(
          create: (_) => HiveSessionSnapshotRepository(),
        ),
        RepositoryProvider<QuranTextRepository>(
          create: (_) => QuranTextRepositoryRealImpl(),
        ),
        RepositoryProvider<TimeProvider>.value(value: timeProvider),
        RepositoryProvider<SrsEngine>(
          create: (_) => SrsEngine(timeProvider),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final authDataSource = FirebaseAuthDataSource();
              final authRepository = AuthRepositoryImpl(authDataSource);
              return AuthCubit(authRepository);
            },
          ),
          BlocProvider<OnboardingCubit>(
            create: (context) => OnboardingCubit(UserProfileRepositoryImpl()),
          ),
          BlocProvider<TodayCubit>(
            create: (context) => TodayCubit(
              generateQueue: GenerateTodayQueue(),
              reviewRepository: context.read<ReviewRepository>(),
              settingsRepository: context.read<SettingsRepository>(),
              snapshotRepository: context.read<SessionSnapshotRepository>(),
              timeProvider: timeProvider,
            ),
          ),
          BlocProvider<AccessGateCubit>(
            create: (context) {
              final profileRepo = UserProfileRepositoryImpl(
                firestore: FirebaseFirestore.instance,
              );
              return AccessGateCubit(profileRepo);
            },
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(ThemeRepositoryImpl()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, currentThemeMode) {
            return MaterialApp(
              title: 'ThikrSpace',
              debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}
