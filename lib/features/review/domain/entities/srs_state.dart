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
}
