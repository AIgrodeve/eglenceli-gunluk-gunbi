class WeeklySummary {
  const WeeklySummary({
    required this.entryCount,
    required this.totalWordCount,
    required this.mostFrequentMoodLabel,
    required this.mostFrequentMoodEmoji,
    required this.longestEntryWordCount,
    required this.distinctMoodCount,
    required this.writtenDayCount,
    required this.weekStart,
    required this.weekEnd,
  });

  final int entryCount;
  final int totalWordCount;
  final String? mostFrequentMoodLabel;
  final String? mostFrequentMoodEmoji;
  final int longestEntryWordCount;
  final int distinctMoodCount;
  final int writtenDayCount;
  final DateTime weekStart;
  final DateTime weekEnd;

  bool get hasEntries => entryCount > 0;

  String get mostFrequentMoodText {
    if (mostFrequentMoodLabel == null || mostFrequentMoodEmoji == null) {
      return 'Henüz yok';
    }

    return '$mostFrequentMoodEmoji $mostFrequentMoodLabel';
  }
}
