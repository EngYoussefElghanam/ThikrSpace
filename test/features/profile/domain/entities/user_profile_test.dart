import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserSettings isOnboarded Logic', () {
    test('returns true when all required fields are present', () {
      const settings = UserSettings(
        surahStart: 114,
        surahEnd: 78,
        dailyNew: 5,
        dailyMaxReviews: 50,
        timezone: 'Africa/Cairo',
      );

      expect(settings.isOnboarded, isTrue);
    });

    test('returns false when surahStart is missing', () {
      const settings = UserSettings(
        surahEnd: 78,
        dailyNew: 5,
        dailyMaxReviews: 50,
        timezone: 'Africa/Cairo',
      );

      expect(settings.isOnboarded, isFalse);
    });

    test('returns false when timezone is empty', () {
      const settings = UserSettings(
        surahStart: 114,
        surahEnd: 78,
        dailyNew: 5,
        dailyMaxReviews: 50,
        timezone: '',
      );

      expect(settings.isOnboarded, isFalse);
    });
  });
}
