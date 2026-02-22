import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../beta_gate/presentation/pages/beta_gate_page.dart';
import '../cubit/auth_cubit.dart';
import 'sign_in_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder listens to the AuthCubit state stream
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Intercept! Send them to the BetaGate, passing the user object.
          return BetaGatePage(user: state.user);
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
