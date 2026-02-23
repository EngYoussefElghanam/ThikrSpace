import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../cubit/access_gate_cubit.dart';

class AccessGatePage extends StatefulWidget {
  final AuthUser user;

  const AccessGatePage({super.key, required this.user});

  @override
  State<AccessGatePage> createState() => _BetaGatePageState();
}

class _BetaGatePageState extends State<AccessGatePage> {
  @override
  void initState() {
    super.initState();
    // Trigger the profile fetch and access evaluation the moment this screen loads
    context.read<AccessGateCubit>().evaluateAccess(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessGateCubit, AccessGateState>(
      listener: (context, state) {
        if (state is AccessGateNeedsOnboarding) {
          // Route to Onboarding (Placeholder for now, we build this next in Prompt 3)
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else if (state is AccessGateAllowed) {
          // Route to Dev Home
          Navigator.of(context).pushReplacementNamed('/dev_home');
        }
      },
      builder: (context, state) {
        if (state is AccessGateLoading || state is AccessGateInitial) {
          return const AppScaffold(
            body: LoadingState(),
          );
        }

        if (state is AccessGateError) {
          return AppScaffold(
            body: ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<AccessGateCubit>()
                  .evaluateAccess(widget.user.id),
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
