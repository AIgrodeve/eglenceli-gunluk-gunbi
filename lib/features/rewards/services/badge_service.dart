import '../models/badge.dart';
import '../models/journal_stats.dart';

class BadgeService {
  const BadgeService();

  List<Badge> evaluate(JournalStats stats) {
    return [
      Badge(
        id: 'first_seed',
        emoji: '🌱',
        title: 'İlk Tohum',
        description: stats.totalEntries > 0
            ? 'İlk yazını günlüğüne ekledin.'
            : 'İlk yazını yazınca açılacak.',
        isUnlocked: stats.totalEntries > 0,
      ),
      Badge(
        id: 'rainy_day',
        emoji: '🌧️',
        title: 'Yağmurlu Gün',
        description: stats.hasSadEntry
            ? 'Hüzünlü hissettiğin bir günde yazdın.'
            : 'Hüzünlü hissettiğin bir gün yazınca açılacak.',
        isUnlocked: stats.hasSadEntry,
      ),
      Badge(
        id: 'colorful',
        emoji: '🌈',
        title: 'Rengarenk',
        description: stats.distinctMoodCount >= 5
            ? 'Beş farklı duyguyla yazdın.'
            : 'Biraz daha farklı duygular seçince açılacak.',
        isUnlocked: stats.distinctMoodCount >= 5,
      ),
      Badge(
        id: 'writer',
        emoji: '📚',
        title: 'Yazar',
        description: stats.totalEntries >= 10
            ? 'On yazı biriktirdin.'
            : 'Biraz daha yazınca açılacak.',
        isUnlocked: stats.totalEntries >= 10,
      ),
      Badge(
        id: 'night_owl',
        emoji: '🌙',
        title: 'Gece Kuşu',
        description: stats.hasNightEntry
            ? 'Gece saatlerinde bir yazı yazdın.'
            : 'Akşam ya da gece yazınca açılacak.',
        isUnlocked: stats.hasNightEntry,
      ),
      Badge(
        id: 'morning_writer',
        emoji: '☀️',
        title: 'Sabahçı',
        description: stats.hasMorningEntry
            ? 'Sabah saatlerinde bir yazı yazdın.'
            : 'Sabah yazınca açılacak.',
        isUnlocked: stats.hasMorningEntry,
      ),
      Badge(
        id: 'long_letter',
        emoji: '💌',
        title: 'Uzun Mektup',
        description: stats.hasLongEntry
            ? 'Tek yazıda 200 kelimeyi geçtin.'
            : 'Uzun bir yazı yazınca açılacak.',
        isUnlocked: stats.hasLongEntry,
      ),
    ];
  }

  List<Badge> newlyUnlocked({
    required JournalStats before,
    required JournalStats after,
  }) {
    final beforeUnlockedIds = evaluate(
      before,
    ).where((badge) => badge.isUnlocked).map((badge) => badge.id).toSet();

    return evaluate(after)
        .where((badge) => badge.isUnlocked)
        .where((badge) => !beforeUnlockedIds.contains(badge.id))
        .take(2)
        .toList();
  }
}
