import '../../journal/models/journal_entry.dart';
import '../models/weekly_summary.dart';

class WeeklySummaryService {
  const WeeklySummaryService();

  WeeklySummary calculate(List<JournalEntry> entries, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final weekStart = _startOfWeek(today);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weeklyEntries = entries.where((entry) {
      final createdAt = entry.createdAt.toLocal();
      return !createdAt.isBefore(weekStart) && createdAt.isBefore(weekEnd);
    }).toList();

    final moodCounts = <String, int>{};
    final moodEmojis = <String, String>{};
    final moodLabels = <String>{};
    final writtenDays = <DateTime>{};
    var totalWordCount = 0;
    var longestEntryWordCount = 0;

    for (final entry in weeklyEntries) {
      final wordCount = _countWords(entry.text);
      totalWordCount += wordCount;
      if (wordCount > longestEntryWordCount) {
        longestEntryWordCount = wordCount;
      }

      moodLabels.add(entry.moodLabel);
      moodCounts[entry.moodLabel] = (moodCounts[entry.moodLabel] ?? 0) + 1;
      moodEmojis[entry.moodLabel] = entry.moodEmoji;
      writtenDays.add(_dateOnly(entry.createdAt.toLocal()));
    }

    String? mostFrequentMoodLabel;
    var highestMoodCount = 0;
    for (final moodEntry in moodCounts.entries) {
      if (moodEntry.value > highestMoodCount) {
        highestMoodCount = moodEntry.value;
        mostFrequentMoodLabel = moodEntry.key;
      }
    }

    return WeeklySummary(
      entryCount: weeklyEntries.length,
      totalWordCount: totalWordCount,
      mostFrequentMoodLabel: mostFrequentMoodLabel,
      mostFrequentMoodEmoji: mostFrequentMoodLabel == null
          ? null
          : moodEmojis[mostFrequentMoodLabel],
      longestEntryWordCount: longestEntryWordCount,
      distinctMoodCount: moodLabels.length,
      writtenDayCount: writtenDays.length,
      weekStart: weekStart,
      weekEnd: weekEnd.subtract(const Duration(milliseconds: 1)),
    );
  }

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime _startOfWeek(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final dayStart = DateTime(localDate.year, localDate.month, localDate.day);
    return dayStart.subtract(Duration(days: localDate.weekday - 1));
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    return trimmed.split(RegExp(r'\s+')).length;
  }
}
