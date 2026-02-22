class UserFlags {
  final bool betaAccess;
  final bool pro;

  const UserFlags({
    this.betaAccess = false,
    this.pro = false,
  });

  factory UserFlags.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserFlags();
    return UserFlags(
      betaAccess: map['betaAccess'] as bool? ?? false,
      pro: map['pro'] as bool? ?? false,
    );
  }

  // Hive local cache only. NEVER sent to Firestore.
  Map<String, dynamic> toMap() => {'betaAccess': betaAccess, 'pro': pro};
}

class UserSettings {
  final int? surahStart;
  final int? surahEnd;
  final int? dailyNew;
  final int? dailyMaxReviews;
  final int khalwaDefaultMinutes;
  final bool clarityEnabled;
  final String timezone;

  const UserSettings({
    this.surahStart,
    this.surahEnd,
    this.dailyNew,
    this.dailyMaxReviews,
    this.khalwaDefaultMinutes = 15,
    this.clarityEnabled = true,
    required this.timezone,
  });

  bool get isOnboarded {
    return surahStart != null &&
        surahEnd != null &&
        dailyNew != null &&
        dailyMaxReviews != null &&
        timezone.isNotEmpty;
  }

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserSettings(timezone: 'UTC');

    // VALIDATION BOUNDS: Clamp values to safe ranges
    int? parseAndClamp(dynamic val, int min, int max) {
      if (val == null) return null;
      final intVal = val as int;
      if (intVal < min) return min;
      if (intVal > max) return max;
      return intVal;
    }

    return UserSettings(
      surahStart: parseAndClamp(map['surahStart'], 1, 114),
      surahEnd: parseAndClamp(map['surahEnd'], 1, 114),
      dailyNew: parseAndClamp(map['dailyNew'], 1, 50), // Max 50 ayahs/day
      dailyMaxReviews: parseAndClamp(map['dailyMaxReviews'], 10, 500),
      khalwaDefaultMinutes:
          parseAndClamp(map['khalwaDefaultMinutes'], 5, 120) ?? 15,
      clarityEnabled: map['clarityEnabled'] as bool? ?? true,
      timezone: map['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surahStart': surahStart,
      'surahEnd': surahEnd,
      'dailyNew': dailyNew,
      'dailyMaxReviews': dailyMaxReviews,
      'khalwaDefaultMinutes': khalwaDefaultMinutes,
      'clarityEnabled': clarityEnabled,
      'timezone': timezone,
    };
  }
}

class UserStats {
  final int currentStreak;
  final int totalMemorized;

  const UserStats({
    this.currentStreak = 0,
    this.totalMemorized = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserStats();
    return UserStats(
      currentStreak: map['currentStreak'] as int? ?? 0,
      totalMemorized: map['totalMemorized'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'totalMemorized': totalMemorized,
      };
}

class UserProfile {
  final String id;
  final UserFlags flags;
  final UserSettings settings;
  final UserStats stats;

  const UserProfile({
    required this.id,
    required this.flags,
    required this.settings,
    required this.stats,
  });

  // SECURITY ENFORCEMENT: Client can only write settings and stats. Flags are silently dropped.
  Map<String, dynamic> toMapForUpdate() {
    return {
      'settings': settings.toMap(),
      'stats': stats.toMap(),
    };
  }
}
