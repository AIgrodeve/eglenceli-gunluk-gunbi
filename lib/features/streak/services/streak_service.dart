import '../../journal/models/journal_entry.dart';
import '../models/streak_stats.dart';

class StreakService {
  const StreakService();

  StreakStats calculate(List<JournalEntry> entries, {DateTime? now}) {
    if (entries.isEmpty) {
      return const StreakStats.empty();
    }

    final today = _dateOnly((now ?? DateTime.now()).toLocal());
    final yesterday = today.subtract(const Duration(days: 1));
    final writtenDays = entries
        .map((entry) => _dateOnly(entry.createdAt.toLocal()))
        .toSet();
    final sortedDays = writtenDays.toList()..sort();
    final lastEntryDate = entries
        .map((entry) => entry.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return StreakStats(
      hasWrittenToday: writtenDays.contains(today),
      currentStreak: _currentStreak(
        writtenDays: writtenDays,
        today: today,
        yesterday: yesterday,
      ),
      bestStreak: _bestStreak(sortedDays),
      lastEntryDate: lastEntryDate,
      totalWrittenDays: writtenDays.length,
      hasWrittenYesterday: writtenDays.contains(yesterday),
    );
  }

  int _currentStreak({
    required Set<DateTime> writtenDays,
    required DateTime today,
    required DateTime yesterday,
  }) {
    if (writtenDays.isEmpty) {
      return 0;
    }

    var cursor = writtenDays.contains(today) ? today : yesterday;
    if (!writtenDays.contains(cursor)) {
      return 0;
    }

    var streak = 0;
    while (writtenDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _bestStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) {
      return 0;
    }

    var best = 1;
    var current = 1;
    for (var index = 1; index < sortedDays.length; index++) {
      final previous = sortedDays[index - 1];
      final day = sortedDays[index];
      if (day.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }

      if (current > best) {
        best = current;
      }
    }
    return best;
  }

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
