class SrsState {
  final double ease;
  final int intervalDays;
  final DateTime dueAt;
  final int reps;
  final int lapses;
  final DateTime lastReviewedAt;

  const SrsState({
    required this.ease,
    required this.intervalDays,
    required this.dueAt,
    required this.reps,
    required this.lapses,
    required this.lastReviewedAt,
  });

  // Overriding toString makes debugging and test output highly readable
  @override
  String toString() {
    return 'SrsState(ease: ${ease.toStringAsFixed(2)}, interval: $intervalDays, reps: $reps, lapses: $lapses)';
  }

  SrsState copyWith({
    double? ease,
    int? intervalDays,
    DateTime? dueAt,
    int? reps,
    int? lapses,
    DateTime? lastReviewedAt,
  }) {
    return SrsState(
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      dueAt: dueAt ?? this.dueAt,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }
}
