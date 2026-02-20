import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'sign_in_page.dart'; // We will build this next
import '../../../beta_gate/presentation/pages/dev_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder listens to the AuthCubit state stream
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Valid session exists -> Let them in
          return const DevHomePage();
        }

        if (state is AuthUnauthenticated || state is AuthError) {
          // No session or signed out -> Force sign in
          return const SignInPage();
        }

        // Default loading state while checking session
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
