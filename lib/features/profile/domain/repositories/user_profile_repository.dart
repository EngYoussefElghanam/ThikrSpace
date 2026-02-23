import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  /// Fetches local profile first, then attempts remote sync.
  Future<UserProfile> getUserProfile(String uid);

  /// Updates user settings locally and remotely.
  Future<void> updateSettings(String uid, UserSettings settings);
}
