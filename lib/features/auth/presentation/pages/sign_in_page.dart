import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/auth_error_mapper.dart'; // <-- IMPORT MAPPER
import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_text_field.dart';
import '../../../../core/ui/app_buttons.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper for premium floating error messages
  void _showErrorSnackBar(
      BuildContext context, String message, ColorScheme colorScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // --- PASS RAW ERROR TO MAPPER ---
            final friendlyMessage =
                AuthErrorMapper.getFriendlyMessage(state.message);
            _showErrorSnackBar(context, friendlyMessage, colorScheme);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    isPassword: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Sign In',
                    isLoading: isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // Dismiss keyboard

                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      // Local validation to prevent empty submissions
                      if (email.isEmpty || password.isEmpty) {
                        _showErrorSnackBar(
                            context,
                            'Please enter both email and password.',
                            colorScheme);
                        return;
                      }

                      context.read<AuthCubit>().signIn(email, password);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.outline, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text(
                          'OR',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.inkSoft,
                                    letterSpacing: 1.5,
                                  ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.outline, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SecondaryButton(
                    text: 'Continue with Google',
                    isLoading: isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () =>
                            Navigator.of(context).pushNamed(AppRoutes.signUp),
                    child: Text(
                      'Need an account? Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
