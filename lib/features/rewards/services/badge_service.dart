import '../../streak/models/streak_stats.dart';
import '../models/badge.dart';
import '../models/journal_stats.dart';

class BadgeService {
  const BadgeService();

  List<Badge> evaluate(
    JournalStats stats, {
    StreakStats streakStats = const StreakStats.empty(),
  }) {
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
      Badge(
        id: 'three_day_streak',
        emoji: '🔥',
        title: '3 Günlük Seri',
        description: streakStats.bestStreak >= 3
            ? '3 gün üst üste yazdın.'
            : '3 gün üst üste yazınca açılacak.',
        isUnlocked: streakStats.bestStreak >= 3,
      ),
      Badge(
        id: 'week_writer',
        emoji: '⭐',
        title: 'Bir Haftalık Yazar',
        description: streakStats.bestStreak >= 7
            ? '7 gün üst üste yazdın.'
            : '7 gün üst üste yazınca açılacak.',
        isUnlocked: streakStats.bestStreak >= 7,
      ),
      Badge(
        id: 'gunbi_friend',
        emoji: '👑',
        title: "Günbi'nin Dostu",
        description: streakStats.bestStreak >= 30
            ? '30 gün üst üste yazdın.'
            : '30 gün üst üste yazınca açılacak.',
        isUnlocked: streakStats.bestStreak >= 30,
      ),
    ];
  }

  List<Badge> newlyUnlocked({
    required JournalStats before,
    required JournalStats after,
    StreakStats beforeStreak = const StreakStats.empty(),
    StreakStats afterStreak = const StreakStats.empty(),
  }) {
    final beforeUnlockedIds = evaluate(
      before,
      streakStats: beforeStreak,
    ).where((badge) => badge.isUnlocked).map((badge) => badge.id).toSet();

    return evaluate(after, streakStats: afterStreak)
        .where((badge) => badge.isUnlocked)
        .where((badge) => !beforeUnlockedIds.contains(badge.id))
        .take(2)
        .toList();
  }
}
