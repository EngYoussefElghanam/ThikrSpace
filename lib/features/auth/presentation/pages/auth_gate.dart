import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../access_gate/presentation/pages/access_gate_page.dart';
import '../cubit/auth_cubit.dart';
import 'sign_in_page.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // 1. Success: Send to the Beta Gate
        if (state is AuthAuthenticated) {
          return AccessGatePage(user: state.user);
        }

        // 2. Initial Boot: Only show full-screen loading when the app first opens
        if (state is AuthInitial) {
          return const AppScaffold(body: LoadingState());
        }

        // 3. For AuthUnauthenticated, AuthError, AND AuthLoading...
        // WE STAY ON THE SIGN IN PAGE!
        // This allows SignInPage's own button to show the spinner and the SnackBar to fire.
        return const SignInPage();
      },
    );
  }
}
