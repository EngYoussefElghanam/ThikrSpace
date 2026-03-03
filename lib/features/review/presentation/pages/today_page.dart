import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/today_cubit.dart';
// TODO: Import your core UI kit and spacing tokens here
// import '../../../../core/theme/app_spacing.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();
    // Fire the queue generation as soon as the page loads
    context.read<TodayCubit>().loadTodayQueue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('ThikrSpace'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<TodayCubit, TodayState>(
        builder: (context, state) {
          if (state is TodayInitial || state is TodayLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodayError) {
            return Center(
              child: Padding(
                // Replace with AppSpacing.lg if available
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  state.message,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is TodayLoaded) {
            if (state.totalCount == 0) {
              return _buildEmptyState(context);
            }

            return _buildActiveState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24), // AppSpacing.lg
          Text(
            'All caught up!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8), // AppSpacing.sm
          Text(
            'You have completed your reviews for today.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context, TodayLoaded state) {
    final theme = Theme.of(context);
    final progress =
        state.totalCount == 0 ? 0.0 : state.completedCount / state.totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0), // AppSpacing.lg
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // 1. Premium Progress Ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  // Background track color (subtle)
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  // Active progress color
                  color: theme.colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.completedCount} / ${state.totalCount}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4), // AppSpacing.xs
                  Text(
                    'Completed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 56), // AppSpacing.xxxl

          // 2. Stats Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(
                label: 'Due Reviews',
                count: state.rawQueue.dueQueue.length,
              ),
              // Vertical Divider token
              Container(
                height: 40,
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              _StatColumn(
                label: 'New Ayahs',
                count: state.rawQueue.newQueue.length,
              ),
            ],
          ),

          const Spacer(),

          // 3. Primary CTA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0), // AppSpacing.lg
              child: SizedBox(
                width: double.infinity,
                height: 56, // Standard touch target height
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Premium rounded corners
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate to ReviewSessionPage, passing state.sessionQueue
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Opening Review Flow...'),
                        backgroundColor: theme.colorScheme.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Start Review',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4), // AppSpacing.xs
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5, // Premium typography touch
          ),
        ),
      ],
    );
  }
}
