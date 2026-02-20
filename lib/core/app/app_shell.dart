import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/onboarding/presentation/pages/boot_page.dart';
import '../../features/beta_gate/presentation/pages/dev_home_page.dart';
import '../routing/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    // We removed the eager instantiation from here!

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) {
            // Because BlocProvider is lazy, this block will NOT run
            // until AuthGate is pushed onto the screen.
            // By then, BootPage has already safely initialized Firebase.
            final authDataSource = FirebaseAuthDataSource();
            final authRepository = AuthRepositoryImpl(authDataSource);
            return AuthCubit(authRepository);
          },
        ),
      ],
      child: MaterialApp(
        title: 'ThikrSpace',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.boot,
        routes: {
          AppRoutes.boot: (_) => const BootPage(),
          AppRoutes.authGate: (_) => const AuthGate(),
          AppRoutes.devHome: (_) => const DevHomePage(),
        },
      ),
    );
  }
}
