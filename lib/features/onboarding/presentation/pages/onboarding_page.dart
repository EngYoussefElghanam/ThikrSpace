import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thikrspace_beta/core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_text_field.dart';
import '../../../../core/ui/app_buttons.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers with sane defaults
  final _startController =
      TextEditingController(text: '114'); // Start at An-Nas
  final _endController = TextEditingController(text: '78'); // End at An-Naba
  final _dailyNewController = TextEditingController(text: '5');
  final _maxReviewsController = TextEditingController(text: '50');

  // Auto-detect device timezone
  final String _timezone = DateTime.now().timeZoneName;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _dailyNewController.dispose();
    _maxReviewsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Grab the user ID from the AuthCubit
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<OnboardingCubit>().completeOnboarding(
              uid: authState.user.id,
              surahStart: int.parse(_startController.text),
              surahEnd: int.parse(_endController.text),
              dailyNew: int.parse(_dailyNewController.text),
              dailyMaxReviews: int.parse(_maxReviewsController.text),
              timezone: _timezone,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Setup Your Journey'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: TextStyle(color: colorScheme.onError)),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is OnboardingSuccess) {
            // Success! Send them to the dev home.
            Navigator.of(context).pushReplacementNamed(AppRoutes.devHome);
          }
        },
        builder: (context, state) {
          final isLoading = state is OnboardingLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to the Beta',
                    style: textTheme.headlineLarge
                        ?.copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Let\'s set up your spaced repetition baseline. You can change these later.',
                    style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- SECTION 1: RANGE ---
                  Text('Target Range (Surah 1-114)',
                      style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _startController,
                          label: 'Start Surah (e.g., 114)',
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          validator: (val) {
                            final num = int.tryParse(val ?? '');
                            if (num == null || num < 1 || num > 114)
                              return 'Must be 1-114';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _endController,
                          label: 'End Surah (e.g., 78)',
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          validator: (val) {
                            final num = int.tryParse(val ?? '');
                            if (num == null || num < 1 || num > 114)
                              return 'Must be 1-114';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // --- SECTION 2: PACE ---
                  Text('Daily Pace', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _dailyNewController,
                          label: 'New Ayahs per Day',
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          validator: (val) {
                            final num = int.tryParse(val ?? '');
                            if (num == null || num < 1 || num > 50)
                              return 'Max 50 new/day';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _maxReviewsController,
                          label: 'Max Reviews per Day',
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          validator: (val) {
                            final num = int.tryParse(val ?? '');
                            if (num == null || num < 10 || num > 500)
                              return 'Must be 10-500';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // --- SECTION 3: TIMEZONE ---
                  AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: colorScheme.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detected Timezone',
                                  style: textTheme.labelLarge),
                              Text(_timezone, style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // --- SUBMIT ---
                  PrimaryButton(
                    text: 'Start Memorizing',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
