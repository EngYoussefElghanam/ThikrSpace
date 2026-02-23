import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart' show AppColors;
import '../../../../core/utils/auth_error_mapper.dart'; // <-- IMPORT MAPPER
import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_text_field.dart';
import '../../../../core/ui/app_buttons.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(
      BuildContext context, String message, ColorScheme colorScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onError)),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
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
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      isPassword: true,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Sign Up',
                      isLoading: isLoading,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirm = _confirmPasswordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          _showErrorSnackBar(context,
                              'Please fill in all fields.', colorScheme);
                          return;
                        }
                        if (password != confirm) {
                          _showErrorSnackBar(
                              context, 'Passwords do not match.', colorScheme);
                          return;
                        }

                        context.read<AuthCubit>().signUp(email, password);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        const Expanded(
                          child:
                              Divider(color: AppColors.outline, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Text(
                            'OR',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.inkSoft,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ),
                        const Expanded(
                          child:
                              Divider(color: AppColors.outline, thickness: 1),
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
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Already have an account? Sign In',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
