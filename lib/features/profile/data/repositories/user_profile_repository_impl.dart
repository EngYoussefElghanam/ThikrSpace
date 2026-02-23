import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    // 1. OFFLINE-FIRST: Load from Hive
    final localData = HiveService.instance
        .get<Map<dynamic, dynamic>>(BoxNames.userProfile, uid);

    UserProfile? localProfile;
    if (localData != null) {
      try {
        // Safely convert Hive's dynamic nested maps into String maps
        localProfile = UserProfile(
          id: uid,
          flags: UserFlags.fromMap(
            localData['flags'] != null
                ? Map<String, dynamic>.from(localData['flags'] as Map)
                : null,
          ),
          settings: UserSettings.fromMap(
            localData['settings'] != null
                ? Map<String, dynamic>.from(localData['settings'] as Map)
                : null,
          ),
          stats: UserStats.fromMap(
            localData['stats'] != null
                ? Map<String, dynamic>.from(localData['stats'] as Map)
                : null,
          ),
        );
      } catch (e) {
        debugPrint('Hive parsing error: $e');
        // If local data is corrupted, we just ignore it and let Firestore fetch fresh data
      }
    }
    // 2. REMOTE SYNC
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final remoteProfile = UserProfile(
          id: uid,
          flags: UserFlags.fromMap(data['flags'] as Map<String, dynamic>?),
          settings:
              UserSettings.fromMap(data['settings'] as Map<String, dynamic>?),
          stats: UserStats.fromMap(data['stats'] as Map<String, dynamic>?),
        );

        // Cache full mapping to local DB
        await HiveService.instance.put(BoxNames.userProfile, uid, {
          'flags': remoteProfile.flags.toMap(),
          'settings': remoteProfile.settings.toMap(),
          'stats': remoteProfile.stats.toMap(),
        });

        return remoteProfile;
      } else {
        // 3. FAILURE MAPPING: Doc missing remotely. Bootstrap a clean, flag-less doc.
        final newSettings = const UserSettings(timezone: 'UTC');
        final newStats = const UserStats();

        // SECURITY: Notice we DO NOT include 'flags' in this payload.
        // Our Day 3 firestore rules check for !('betaAccess' in request.resource.data).
        final initialData = {
          'settings': newSettings.toMap(),
          'stats': newStats.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(uid).set(initialData);

        final newProfile = UserProfile(
          id: uid,
          flags: const UserFlags(),
          settings: newSettings,
          stats: newStats,
        );

        // Cache to Hive
        await HiveService.instance.put(BoxNames.userProfile, uid, {
          'flags': newProfile.flags.toMap(),
          'settings': newProfile.settings.toMap(),
          'stats': newProfile.stats.toMap(),
        });

        return newProfile;
      }
    } catch (e) {
      // 4. OFFLINE FALLBACK
      if (localProfile != null) {
        return localProfile;
      }
      throw Exception(
          'Network offline and no local profile found for $uid. Please connect to the internet.');
    }
  }

  @override
  Future<void> updateSettings(String uid, UserSettings settings) async {
    // 1. Update remote (Firestore limits to 'settings' key)
    await _firestore.collection('users').doc(uid).set(
      {'settings': settings.toMap()},
      SetOptions(merge: true),
    );

    // 2. Update local Hive without overwriting flags/stats
    final localData = HiveService.instance
        .get<Map<dynamic, dynamic>>(BoxNames.userProfile, uid);
    final currentMap = localData != null
        ? Map<String, dynamic>.from(localData)
        : <String, dynamic>{};

    currentMap['settings'] = settings.toMap();
    await HiveService.instance.put(BoxNames.userProfile, uid, currentMap);
  }
}
