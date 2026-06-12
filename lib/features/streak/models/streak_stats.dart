class StreakStats {
  const StreakStats({
    required this.hasWrittenToday,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastEntryDate,
    required this.totalWrittenDays,
    required this.hasWrittenYesterday,
  });

  const StreakStats.empty()
    : hasWrittenToday = false,
      currentStreak = 0,
      bestStreak = 0,
      lastEntryDate = null,
      totalWrittenDays = 0,
      hasWrittenYesterday = false;

  final bool hasWrittenToday;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastEntryDate;
  final int totalWrittenDays;
  final bool hasWrittenYesterday;

  bool get hasAnyEntry => totalWrittenDays > 0;
  bool get canStartFreshToday =>
      hasAnyEntry && !hasWrittenToday && !hasWrittenYesterday;
}
