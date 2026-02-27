import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thikrspace_beta/core/routing/app_routes.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_buttons.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _startSurah = 114;
  int _endSurah = 78;

  int _dailyNew = 5; // keep aligned with rules
  int _dailyMaxReviews = 50; // keep aligned with rules

  late final String _timezone;

  @override
  void initState() {
    super.initState();
    _timezone = DateTime.now().timeZoneName;
  }

  bool get _isBackwards => _startSurah > _endSurah;

  String get _rangeSummary {
    final direction = _startSurah == _endSurah
        ? 'Single Surah'
        : _isBackwards
            ? 'Backwards'
            : 'Forwards';
    return 'Surah $_startSurah → $_endSurah • $direction';
  }

  Future<void> _pickStartSurah({required bool disabled}) async {
    if (disabled) return;
    final picked = await _showSurahPicker(
      context: context,
      title: 'Start Surah',
      initial: _startSurah,
    );
    if (picked == null) return;
    setState(() => _startSurah = picked);
  }

  Future<void> _pickEndSurah({required bool disabled}) async {
    if (disabled) return;
    final picked = await _showSurahPicker(
      context: context,
      title: 'End Surah',
      initial: _endSurah,
    );
    if (picked == null) return;
    setState(() => _endSurah = picked);
  }

  void _applyPreset(_RangePreset preset) {
    setState(() {
      _startSurah = preset.startSurah;
      _endSurah = preset.endSurah;
    });
  }

  void _submit({required bool disabled}) {
    if (disabled) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to continue.')),
      );
      return;
    }

    if (_startSurah < 1 ||
        _startSurah > 114 ||
        _endSurah < 1 ||
        _endSurah > 114) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surah range must be between 1 and 114.')),
      );
      return;
    }
    if (_dailyNew < 1 || _dailyNew > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily new must be between 1 and 20.')),
      );
      return;
    }
    if (_dailyMaxReviews < 1 || _dailyMaxReviews > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max reviews must be between 1 and 200.')),
      );
      return;
    }

    context.read<OnboardingCubit>().completeOnboarding(
          uid: authState.user.id,
          surahStart: _startSurah,
          surahEnd: _endSurah,
          dailyNew: _dailyNew,
          dailyMaxReviews: _dailyMaxReviews,
          timezone: _timezone,
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OnboardingSuccess) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.devHome);
          }
        },
        builder: (context, state) {
          final isLoading = state is OnboardingLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Set your baseline', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A calm daily plan. You can change this later in Settings.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const _SectionDivider(),
                _SectionHeader(
                  title: 'Memorization range',
                  subtitle: _rangeSummary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    children: [
                      _PresetRow(
                        disabled: isLoading,
                        selectedStart: _startSurah,
                        selectedEnd: _endSurah,
                        onPreset: _applyPreset,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _CardDivider(),
                      const SizedBox(height: AppSpacing.md),
                      _PickerRow(
                        label: 'Start',
                        value: 'Surah $_startSurah',
                        onTap: () => _pickStartSurah(disabled: isLoading),
                        disabled: isLoading,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _CardDivider(),
                      const SizedBox(height: AppSpacing.sm),
                      _PickerRow(
                        label: 'End',
                        value: 'Surah $_endSurah',
                        onTap: () => _pickEndSurah(disabled: isLoading),
                        disabled: isLoading,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _startSurah == _endSurah
                            ? 'You’ll focus on a single surah.'
                            : _isBackwards
                                ? 'Direction: Start → End (backwards).'
                                : 'Direction: Start → End (forwards).',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const _SectionDivider(),
                const _SectionHeader(
                  title: 'Daily pace',
                  subtitle: 'Keep it sustainable. Consistency beats intensity.',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    children: [
                      _StepperRow(
                        label: 'New ayahs / day',
                        value: _dailyNew,
                        min: 1,
                        max: 20,
                        step: 1,
                        disabled: isLoading,
                        onChanged: (v) => setState(() => _dailyNew = v),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _CardDivider(),
                      const SizedBox(height: AppSpacing.sm),
                      _StepperRow(
                        label: 'Max reviews / day',
                        value: _dailyMaxReviews,
                        min: 1,
                        max: 200,
                        step: 5,
                        disabled: isLoading,
                        onChanged: (v) => setState(() => _dailyMaxReviews = v),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tip: Start smaller. You can raise the pace later.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const _SectionDivider(),
                const _SectionHeader(
                  title: 'Timezone',
                  subtitle: 'Used to generate your daily queue correctly.',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device timezone',
                                style: textTheme.labelLarge),
                            const SizedBox(height: AppSpacing.xs),
                            Text(_timezone, style: textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  text: 'Start',
                  isLoading: isLoading,
                  onPressed: () => _submit(disabled: isLoading),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'You can change these later in Settings.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// --- Small UI helpers ---

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Divider(
        height: 1,
        thickness: 1,
        color: dividerColor,
      ),
    );
  }
}

/// Divider intended for inside AppCard blocks (slightly tighter spacing).
class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return Divider(
      height: 1,
      thickness: 1,
      color: dividerColor,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style:
                textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool disabled;

  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: textTheme.bodyLarge),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.disabled,
    required this.onChanged,
  });

  void _inc() => onChanged((value + step).clamp(min, max));
  void _dec() => onChanged((value - step).clamp(min, max));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.labelLarge)),
        IconButton(
          onPressed: disabled || value <= min ? null : _dec,
          icon: const Icon(Icons.remove),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$value', style: textTheme.titleMedium),
        ),
        IconButton(
          onPressed: disabled || value >= max ? null : _inc,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _RangePreset {
  final String label;
  final int startSurah;
  final int endSurah;

  const _RangePreset({
    required this.label,
    required this.startSurah,
    required this.endSurah,
  });
}

class _PresetRow extends StatelessWidget {
  final bool disabled;
  final int selectedStart;
  final int selectedEnd;
  final void Function(_RangePreset preset) onPreset;

  const _PresetRow({
    required this.disabled,
    required this.selectedStart,
    required this.selectedEnd,
    required this.onPreset,
  });

  static const _presets = <_RangePreset>[
    _RangePreset(label: "Juz' Amma", startSurah: 114, endSurah: 78),
    _RangePreset(label: 'Last 10', startSurah: 114, endSurah: 105),
    _RangePreset(label: 'Last 5', startSurah: 114, endSurah: 110),
  ];

  bool _isSelected(_RangePreset p) =>
      p.startSurah == selectedStart && p.endSurah == selectedEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final p = _presets[i];
          return ChoiceChip(
            label: Text(p.label),
            selected: _isSelected(p),
            onSelected: disabled ? null : (_) => onPreset(p),
          );
        },
      ),
    );
  }
}

Future<int?> _showSurahPicker({
  required BuildContext context,
  required String title,
  required int initial,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '1–114',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: 114,
                itemBuilder: (ctx, index) {
                  final surah = index + 1;
                  return ListTile(
                    title: Text('Surah $surah'),
                    trailing: surah == initial ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(ctx).pop(surah),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
