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
  });

  final int totalEntries;
  final int totalWords;
  final int distinctMoodCount;
  final DateTime? lastEntryDate;
  final bool hasMorningEntry;
  final bool hasNightEntry;
  final bool hasLongEntry;
  final bool hasSadEntry;

  factory JournalStats.fromEntries(List<JournalEntry> entries) {
    final moodLabels = <String>{};
    var totalWords = 0;
    var hasMorningEntry = false;
    var hasNightEntry = false;
    var hasLongEntry = false;
    var hasSadEntry = false;
    DateTime? lastEntryDate;

    for (final entry in entries) {
      final wordCount = _countWords(entry.text);
      totalWords += wordCount;
      moodLabels.add(entry.moodLabel);
      hasLongEntry = hasLongEntry || wordCount >= 200;
      hasSadEntry = hasSadEntry || entry.moodLabel == 'Hüzünlü';

      final localDate = entry.createdAt.toLocal();
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
    );
  }

  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    return trimmed.split(RegExp(r'\s+')).length;
  }
}
