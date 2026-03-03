import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_buttons.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';
import '../../../review_session/presentation/pages/review_session_page.dart';
import '../cubit/today_cubit.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodayCubit>().loadTodayQueue();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Today')),
      body: BlocBuilder<TodayCubit, TodayState>(
        builder: (context, state) {
          if (state is TodayInitial || state is TodayLoading) {
            return const LoadingState();
          }
          if (state is TodayError) {
            return ErrorState(
              message: state.message,
              onRetry: context.read<TodayCubit>().loadTodayQueue,
            );
          }

          final loaded = state as TodayLoaded;
          if (loaded.totalCount == 0) {
            return const EmptyState(message: 'No ayahs queued for today.');
          }

          final progress = loaded.totalCount == 0
              ? 0.0
              : loaded.completedCount / loaded.totalCount;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Progress', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${loaded.completedCount}/${loaded.totalCount} completed',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CountRow(label: 'Due', count: loaded.rawQueue.dueQueue.length),
                    const SizedBox(height: AppSpacing.xs),
                    _CountRow(label: 'New', count: loaded.rawQueue.newQueue.length),
                    const SizedBox(height: AppSpacing.xs),
                    _CountRow(label: 'Total', count: loaded.totalCount),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: loaded.hasSnapshot ? 'Resume Review' : 'Start Review',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReviewSessionPage(
                        dayKey: loaded.dayKey,
                        queue: loaded.sessionQueue,
                        snapshot: loaded.snapshot,
                      ),
                    ),
                  );
                  if (mounted) {
                    context.read<TodayCubit>().loadTodayQueue();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int count;

  const _CountRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text('$count', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
