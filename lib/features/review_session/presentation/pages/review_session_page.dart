import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_provider.dart';
import '../../../../core/ui/app_buttons.dart';
import '../../../../core/ui/app_card.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../quran/domain/repositories/quran_text_repository.dart';
import '../../../review/domain/entities/queue_entities.dart';
import '../../../review/domain/repositories/review_repository.dart';
import '../../../review/domain/repositories/settings_repository.dart';
import '../../../review/domain/services/srs_engine.dart';
import '../../domain/entities/review_chunk.dart';
import '../../domain/entities/session_snapshot.dart';
import '../../domain/repositories/session_snapshot_repository.dart';
import '../../domain/usecases/apply_chunk_review.dart';
import '../../domain/usecases/derive_review_chunk.dart';
import '../cubit/review_session_cubit.dart';
import '../widgets/mushaf_peek_bottom_sheet.dart';

class ReviewSessionPage extends StatelessWidget {
  final String dayKey;
  final List<AyahRef> queue;
  final SessionSnapshot? snapshot;

  const ReviewSessionPage({
    super.key,
    required this.dayKey,
    required this.queue,
    this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final timeProvider = context.read<TimeProvider>();
    return BlocProvider(
      create: (context) => ReviewSessionCubit(
        deriveReviewChunk: DeriveReviewChunk(),
        applyChunkReview: ApplyChunkReview(
          reviewRepository: context.read<ReviewRepository>(),
          settingsRepository: context.read<SettingsRepository>(),
          srsEngine: context.read<SrsEngine>(),
        ),
        snapshotRepository: context.read<SessionSnapshotRepository>(),
        reviewRepository: context.read<ReviewRepository>(),
        timeProvider: timeProvider,
      )..start(dayKey: dayKey, queue: queue, snapshot: snapshot),
      child: BlocConsumer<ReviewSessionCubit, ReviewSessionState>(
        listener: (context, state) {
          if (state is ReviewSessionCompleted) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          if (state is ReviewSessionInitial) {
            return const AppScaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state is ReviewSessionError) {
            return AppScaffold(
              appBar: AppBar(title: const Text('Review Session')),
              body: Center(child: Text(state.message)),
            );
          }

          final active = state as ReviewSessionActive;
          final chunk = active.currentChunk;
          return AppScaffold(
            appBar: AppBar(title: const Text('Review Session')),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Surah ${chunk.startRef.surah}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Ayahs ${chunk.startRef.ayah} - ${chunk.endRef.ayah}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${active.completedAyahsCount}/${active.totalAyahs} completed',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  text: 'Peek Mushaf',
                  onPressed: () => _openMushafPeek(context, chunk),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Done Reciting',
                  isLoading: active.isSubmitting,
                  onPressed: active.isSubmitting
                      ? null
                      : () => _showRatingSheet(context, active),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openMushafPeek(BuildContext context, ReviewChunk chunk) async {
    final quranRepository = context.read<QuranTextRepository>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MushafPeekBottomSheet(
        quranTextRepository: quranRepository,
        surah: chunk.startRef.surah,
        startAyah: chunk.startRef.ayah,
        endAyah: chunk.endRef.ayah,
      ),
    );
  }

  Future<void> _showRatingSheet(
      BuildContext context, ReviewSessionActive active) async {
    final chunk = active.currentChunk;
    int chunkRating = 4;
    final overrides = <int, int>{};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Rate this chunk', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return ChoiceChip(
                        label: Text('$value'),
                        selected: chunkRating == value,
                        onSelected: (_) => setState(() => chunkRating = value),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Per-ayah overrides (optional)',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final ayah in chunk.ayahs)
                        PopupMenuButton<int>(
                          onSelected: (value) => setState(() {
                            overrides[ayah.ayah] = value;
                          }),
                          itemBuilder: (_) => List.generate(
                            5,
                            (index) => PopupMenuItem<int>(
                              value: index + 1,
                              child: Text('Rating ${index + 1}'),
                            ),
                          ),
                          child: Chip(
                            label: Text(
                              overrides.containsKey(ayah.ayah)
                                  ? 'Ayah ${ayah.ayah}: ${overrides[ayah.ayah]}'
                                  : 'Ayah ${ayah.ayah}',
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    text: 'Submit',
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.read<ReviewSessionCubit>().submitChunk(
                            chunkRating: chunkRating,
                            perAyahOverrides: overrides,
                          );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
