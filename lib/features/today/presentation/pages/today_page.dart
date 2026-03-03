import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_buttons.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_states.dart';
import '../../../review/domain/entities/queue_entities.dart';
import '../../../review_session/domain/entities/session_snapshot.dart';
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

          final progress = loaded.completedCount / loaded.totalCount;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Today', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your daily queue is ready.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CountRow(label: 'Due reviews', count: loaded.dueCount),
                    const SizedBox(height: AppSpacing.xs),
                    _CountRow(label: 'New items', count: loaded.newCount),
                    const SizedBox(height: AppSpacing.xs),
                    _CountRow(label: 'Total', count: loaded.totalCount),
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(value: progress.clamp(0, 1)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${loaded.completedCount}/${loaded.totalCount} completed',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (loaded.isCompleted) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.successLight),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Today\'s goal complete',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    PrimaryButton(
                      text: loaded.hasSnapshot ? 'Resume Review' : 'Start Review',
                      onPressed: () => _openReviewSession(
                        context: context,
                        loaded: loaded,
                        queue: loaded.sessionQueue,
                        snapshot: loaded.snapshot,
                        isExtraMode: false,
                      ),
                    ),
                    if (loaded.isCompleted && loaded.hasOverflowDue) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SecondaryButton(
                        text: 'Keep going (optional)',
                        onPressed: () => _openReviewSession(
                          context: context,
                          loaded: loaded,
                          queue: loaded.overflowDueQueue,
                          snapshot: null,
                          isExtraMode: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openReviewSession({
    required BuildContext context,
    required TodayLoaded loaded,
    required List<AyahRef> queue,
    required bool isExtraMode,
    required SessionSnapshot? snapshot,
  }) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(
          dayKey: loaded.dayKey,
          queue: queue,
          snapshot: snapshot,
          isExtraMode: isExtraMode,
          hasOptionalOverflow: loaded.hasOverflowDue,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == ReviewSessionPage.keepGoingOptionalResult && !isExtraMode) {
      await _openReviewSession(
        context: context,
        loaded: loaded,
        queue: loaded.overflowDueQueue,
        isExtraMode: true,
        snapshot: null,
      );
      return;
    }

    context.read<TodayCubit>().loadTodayQueue();
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
