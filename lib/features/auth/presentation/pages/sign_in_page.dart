import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Notice we use AppScaffold here. It automatically adds the 16px horizontal padding.
    return AppScaffold(
      appBar: AppBar(
          title: const Text('Sign In'),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(color: colorScheme.onError),
                ),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: AppCard(
              // The card automatically applies the 20px radius and 16px internal padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content tightly
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
                    isLoading:
                        isLoading, // Button handles the spinner logic internally now!
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      if (email.isNotEmpty && password.isNotEmpty) {
                        context.read<AuthCubit>().signIn(email, password);
                      }
                    },
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
