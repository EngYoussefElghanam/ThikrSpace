import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../cubit/beta_gate_cubit.dart';
import 'beta_blocked_screen.dart';

class BetaGatePage extends StatefulWidget {
  final AuthUser user;

  const BetaGatePage({super.key, required this.user});

  @override
  State<BetaGatePage> createState() => _BetaGatePageState();
}

class _BetaGatePageState extends State<BetaGatePage> {
  @override
  void initState() {
    super.initState();
    // Trigger the profile fetch and access evaluation the moment this screen loads
    context.read<BetaGateCubit>().evaluateAccess(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BetaGateCubit, BetaGateState>(
      listener: (context, state) {
        if (state is BetaGateNeedsOnboarding) {
          // Route to Onboarding (Placeholder for now, we build this next in Prompt 3)
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else if (state is BetaGateAllowed) {
          // Route to Dev Home
          Navigator.of(context).pushReplacementNamed('/dev_home');
        }
      },
      builder: (context, state) {
        if (state is BetaGateLoading || state is BetaGateInitial) {
          return const AppScaffold(
            body: LoadingState(),
          );
        }

        if (state is BetaGateDenied) {
          return BetaBlockedScreen(message: state.message);
        }

        if (state is BetaGateError) {
          return AppScaffold(
            body: ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<BetaGateCubit>().evaluateAccess(widget.user.id),
            ),
          );
        }

        // Fallback (should ideally never be visible long enough to read)
        return const AppScaffold(
          body: LoadingState(),
        );
      },
    );
  }
}
