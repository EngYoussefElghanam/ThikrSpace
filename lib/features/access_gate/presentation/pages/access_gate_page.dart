import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../cubit/access_gate_cubit.dart';

class AccessGatePage extends StatefulWidget {
  final AuthUser user;

  const AccessGatePage({super.key, required this.user});

  @override
  State<AccessGatePage> createState() => _AccessGatePageState();
}

class _AccessGatePageState extends State<AccessGatePage> {
  @override
  void initState() {
    super.initState();
    // 1. Instantly trigger the access check the moment the user arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessGateCubit>().evaluateAccess(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Wrap the ENTIRE page in AppScaffold to guarantee your Parchment background
    // is always applied, completely preventing the "Dark Screen".
    return AppScaffold(
      body: BlocConsumer<AccessGateCubit, AccessGateState>(
        listener: (context, state) {
          // 3. Routing logic based on onboarding status
          if (state is AccessGateNeedsOnboarding) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.onBoarding);
          } else if (state is AccessGateAllowed) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.devHome);
          } else if (state is AccessGateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onError)),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // If the profile is actively being created in Firestore, show the spinner cleanly
          if (state is AccessGateLoading) {
            return const LoadingState();
          }

          // Fallback empty state while waiting for the Cubit to initialize
          return const Center(child: SizedBox.shrink());
        },
      ),
    );
  }
}
