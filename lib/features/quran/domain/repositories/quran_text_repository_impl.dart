import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/repositories/quran_text_repository.dart';

class QuranTextRepositoryRealImpl implements QuranTextRepository {
  // Caches the ayahs for a Surah so we don't read from disk repeatedly
  final Map<int, List<String>> _surahCache = {};

  Future<void> _loadSurahIfNeeded(int surah) async {
    if (_surahCache.containsKey(surah)) return;

    // Format the surah number to 3 digits (e.g., 1 -> "001", 114 -> "114")
    final fileName = surah.toString().padLeft(3, '0');
    final filePath = 'assets/quran/uthmani/$fileName.json';

    try {
      final jsonString = await rootBundle.loadString(filePath);
      final data = jsonDecode(jsonString);

      // The Python script created {"surah": 1, "ayahs": ["...", "..."]}
      // We cast the dynamic list to a strongly typed List<String>
      _surahCache[surah] = List<String>.from(data['ayahs']);
    } catch (e) {
      throw Exception('Failed to load Surah $surah from $filePath: $e');
    }
  }

  @override
  Future<String> getAyah(int surah, int ayah) async {
    await _loadSurahIfNeeded(surah);

    final ayahs = _surahCache[surah]!;
    if (ayah < 1 || ayah > ayahs.length) {
      throw ArgumentError('Invalid ayah $ayah for surah $surah');
    }

    // Ayah 1 is at index 0 in the list
    return ayahs[ayah - 1];
  }

  @override
  Future<List<String>> getRange(int surah, int startAyah, int endAyah) async {
    await _loadSurahIfNeeded(surah);

    final ayahs = _surahCache[surah]!;
    if (startAyah < 1 || endAyah > ayahs.length || startAyah > endAyah) {
      throw ArgumentError('Invalid range $startAyah-$endAyah for surah $surah');
    }

    // List.sublist is inclusive for start, exclusive for end.
    // To get ayahs 1 to 3, we want indices 0 to 3.
    return ayahs.sublist(startAyah - 1, endAyah);
  }
}
