import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Domain Interface
abstract class QuranTextRepository {
  Future<String> getAyah(int surah, int ayah);
  Future<List<String>> getRange(int surah, int startAyah, int endAyah);
}

/// Local JSON Implementation with a Fallback Stub
class QuranTextRepositoryJsonImpl implements QuranTextRepository {
  Map<String, dynamic>? _cachedQuranData;

  /// Loads the JSON file into memory if it hasn't been loaded yet.
  Future<void> _loadDataIfNeeded() async {
    if (_cachedQuranData != null) return;

    try {
      // Simulate slight disk read delay for UI loading state testing
      await Future.delayed(const Duration(milliseconds: 100));

      final String jsonString =
          await rootBundle.loadString('assets/json/quran_sample.json');
      _cachedQuranData = jsonDecode(jsonString);
    } catch (e) {
      // If the file is missing or malformed, fallback to empty so it uses stub logic
      _cachedQuranData = {};
    }
  }

  @override
  Future<String> getAyah(int surah, int ayah) async {
    await _loadDataIfNeeded();

    final surahKey = surah.toString();
    final ayahKey = ayah.toString();

    // If the Surah and Ayah exist in our sample JSON, return the real Arabic!
    if (_cachedQuranData!.containsKey(surahKey) &&
        _cachedQuranData![surahKey].containsKey(ayahKey)) {
      return _cachedQuranData![surahKey][ayahKey];
    }

    // Otherwise, gracefully fallback to the stub text so the app doesn't crash
    return "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (Stub for S$surah:A$ayah)";
  }

  @override
  Future<List<String>> getRange(int surah, int startAyah, int endAyah) async {
    await _loadDataIfNeeded();

    List<String> range = [];
    for (int i = startAyah; i <= endAyah; i++) {
      final surahKey = surah.toString();
      final ayahKey = i.toString();

      if (_cachedQuranData!.containsKey(surahKey) &&
          _cachedQuranData![surahKey].containsKey(ayahKey)) {
        range.add(_cachedQuranData![surahKey][ayahKey]);
      } else {
        range.add("Stub text for S$surah:A$i");
      }
    }
    return range;
  }
}
