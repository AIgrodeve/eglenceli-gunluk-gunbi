import '../../journal/models/journal_entry.dart';

class JournalStats {
  const JournalStats({
    required this.totalEntries,
    required this.totalWords,
    required this.distinctMoodCount,
    required this.lastEntryDate,
    required this.hasMorningEntry,
    required this.hasNightEntry,
    required this.hasLongEntry,
    required this.hasSadEntry,
    required this.longEntryCount,
    required this.titledEntryCount,
    required this.maxWeeklyEntryCount,
    required this.moodDayVarietyCount,
  });

  final int totalEntries;
  final int totalWords;
  final int distinctMoodCount;
  final DateTime? lastEntryDate;
  final bool hasMorningEntry;
  final bool hasNightEntry;
  final bool hasLongEntry;
  final bool hasSadEntry;
  final int longEntryCount;
  final int titledEntryCount;
  final int maxWeeklyEntryCount;
  final int moodDayVarietyCount;

  factory JournalStats.fromEntries(List<JournalEntry> entries) {
    final moodLabels = <String>{};
    var totalWords = 0;
    var hasMorningEntry = false;
    var hasNightEntry = false;
    var hasLongEntry = false;
    var hasSadEntry = false;
    var longEntryCount = 0;
    var titledEntryCount = 0;
    final weeklyEntryCounts = <DateTime, int>{};
    final moodDays = <String>{};
    DateTime? lastEntryDate;

    for (final entry in entries) {
      final wordCount = _countWords(entry.text);
      totalWords += wordCount;
      moodLabels.add(entry.moodLabel);
      hasLongEntry = hasLongEntry || wordCount >= 200;
      if (wordCount >= 100) {
        longEntryCount++;
      }
      hasSadEntry = hasSadEntry || entry.moodLabel == 'Hüzünlü';
      if (entry.title?.trim().isNotEmpty == true) {
        titledEntryCount++;
      }

      final localDate = entry.createdAt.toLocal();
      final weekStart = _startOfWeek(localDate);
      weeklyEntryCounts[weekStart] = (weeklyEntryCounts[weekStart] ?? 0) + 1;
      moodDays.add(
        '${localDate.year}-${localDate.month}-${localDate.day}:${entry.moodLabel}',
      );
      hasMorningEntry =
          hasMorningEntry || localDate.hour >= 6 && localDate.hour < 12;
      hasNightEntry =
          hasNightEntry || localDate.hour >= 20 || localDate.hour < 6;

      if (lastEntryDate == null || entry.createdAt.isAfter(lastEntryDate)) {
        lastEntryDate = entry.createdAt;
      }
    }

    return JournalStats(
      totalEntries: entries.length,
      totalWords: totalWords,
      distinctMoodCount: moodLabels.length,
      lastEntryDate: lastEntryDate,
      hasMorningEntry: hasMorningEntry,
      hasNightEntry: hasNightEntry,
      hasLongEntry: hasLongEntry,
      hasSadEntry: hasSadEntry,
      longEntryCount: longEntryCount,
      titledEntryCount: titledEntryCount,
      maxWeeklyEntryCount: weeklyEntryCounts.values.fold(
        0,
        (highest, count) => count > highest ? count : highest,
      ),
      moodDayVarietyCount: moodDays.length,
    );
  }

  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    return trimmed.split(RegExp(r'\s+')).length;
  }

  static DateTime _startOfWeek(DateTime dateTime) {
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
