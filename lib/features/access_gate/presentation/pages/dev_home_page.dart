import 'package:flutter/material.dart';
// Make sure this import path matches where you put the Impl file!
import 'package:thikrspace_beta/features/quran/domain/repositories/quran_text_repository_impl.dart';

class DevHomePage extends StatefulWidget {
  const DevHomePage({super.key});

  @override
  State<DevHomePage> createState() => _DevHomePageState();
}

class _DevHomePageState extends State<DevHomePage> {
  // Instantiate the real repository we just built
  final QuranTextRepositoryRealImpl _quranRepo = QuranTextRepositoryRealImpl();

  // A Future to hold our text loading
  late Future<List<String>> _surahTextFuture;

  @override
  void initState() {
    super.initState();
    // Let's load Surah 112 (Al-Ikhlas), Ayahs 1 through 4
    _surahTextFuture = _quranRepo.getRange(112, 1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arabic Text Rendering Test')),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<List<String>>(
            future: _surahTextFuture,
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              // 2. Error State (e.g., if JSON file is missing)
              if (snapshot.hasError) {
                return Text(
                  'Error loading JSON:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                );
              }

              // 3. Success State
              final ayahs = snapshot.data!;

              // Combine the ayahs with the traditional Ayah end symbol (۝) and the number
              // Note: Arabic numbers are used (١, ٢, ٣, ٤)
              final arabicNumbers = ['١', '٢', '٣', '٤'];
              String fullSurah = '';
              for (int i = 0; i < ayahs.length; i++) {
                fullSurah += '${ayahs[i]} ﴿${arabicNumbers[i]}﴾ ';
              }

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'سورة الإخلاص',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // THE CRITICAL TEXT WIDGET
                      Text(
                        fullSurah.trim(),
                        // Explicitly force Right-to-Left rendering
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          // A large font size makes the Uthmani script easy to read
                          fontSize: 32,
                          // A taller line height prevents the diacritics (tashkeel) from clipping
                          height: 1.8,
                          // If you add a custom Arabic font later (like KFGQPC), apply its fontFamily here!
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
