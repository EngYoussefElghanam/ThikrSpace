import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../quran/domain/repositories/quran_text_repository.dart';

class MushafPeekBottomSheet extends StatelessWidget {
  final QuranTextRepository quranTextRepository;
  final int surah;
  final int startAyah;
  final int endAyah;

  const MushafPeekBottomSheet({
    super.key,
    required this.quranTextRepository,
    required this.surah,
    required this.startAyah,
    required this.endAyah,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: FutureBuilder<List<String>>(
        future: quranTextRepository.getRange(surah, startAyah, endAyah),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final lines = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Surah $surah • Ayah $startAyah-$endAyah',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < lines.length; i++) ...[
                  Text(
                    '${startAyah + i}. ${lines[i]}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
