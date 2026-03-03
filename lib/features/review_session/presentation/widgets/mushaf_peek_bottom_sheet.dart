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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(
          color: colors.outlineVariant,
          width: 1.5,
        ),
      ),
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

          final ayat = snapshot.data!;

          /// Build the entire mushaf text as one long inline paragraph.
          List<InlineSpan> spans = [];

          for (var i = 0; i < ayat.length; i++) {
            spans.add(
              TextSpan(
                text: ayat[i] + " ",
                style: textTheme.bodyLarge?.copyWith(
                  fontFamily: 'NotoNaskhArabic', // or any mushaf font
                  fontSize: 24,
                  height: 2,
                  color: colors.onSurface,
                ),
              ),
            );

            spans.add(
              TextSpan(
                text: '﴿${startAyah + i}﴾ ',
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 20,
                  color: colors.primary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // BISMILLAH
                Text(
                  '﷽',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: 'NotoNaskhArabic',
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // MUSHAF PARAGRAPH FLOW
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    TextSpan(children: spans),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
