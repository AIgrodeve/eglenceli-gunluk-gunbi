import '../../streak/models/streak_stats.dart';
import '../models/badge.dart';
import '../models/journal_stats.dart';
import '../models/reward_activity_stats.dart';

class BadgeService {
  const BadgeService();

  List<Badge> evaluate(
    JournalStats stats, {
    StreakStats streakStats = const StreakStats.empty(),
    RewardActivityStats activityStats = const RewardActivityStats.empty(),
    bool isPremiumUnlocked = false,
  }) {
    return [
      _freeBadge(
        id: 'first_seed',
        emoji: '🌱',
        title: 'İlk Tohum',
        condition: stats.totalEntries >= 1,
        unlockedDescription: 'İlk yazını günlüğüne ekledin.',
        lockedDescription: 'İlk yazını yazınca açılacak.',
      ),
      _freeBadge(
        id: 'three_entry_writer',
        emoji: '✏️',
        title: 'Üç Günlük Yazar',
        condition: stats.totalEntries >= 3,
        unlockedDescription: 'Üç yazı biriktirdin.',
        lockedDescription: '3 yazı ekleyince açılacak.',
      ),
      _freeBadge(
        id: 'five_entry_writer',
        emoji: '📝',
        title: 'Beş Günlük Yazar',
        condition: stats.totalEntries >= 5,
        unlockedDescription: 'Beş yazı biriktirdin.',
        lockedDescription: '5 yazı ekleyince açılacak.',
      ),
      _freeBadge(
        id: 'colorful_emotions',
        emoji: '🌈',
        title: 'Rengarenk Duygular',
        condition: stats.distinctMoodCount >= 3,
        unlockedDescription: 'Üç farklı duyguyla yazdın.',
        lockedDescription: '3 farklı duygu seçince açılacak.',
      ),
      _freeBadge(
        id: 'morning_writer',
        emoji: '☀️',
        title: 'Sabah Yazarı',
        condition: stats.hasMorningEntry,
        unlockedDescription: 'Sabah saatlerinde yazdın.',
        lockedDescription: 'Sabah yazınca açılacak.',
      ),
      _freeBadge(
        id: 'night_owl',
        emoji: '🌙',
        title: 'Gece Kuşu',
        condition: stats.hasNightEntry,
        unlockedDescription: 'Akşam ya da gece yazdın.',
        lockedDescription: 'Akşam ya da gece yazınca açılacak.',
      ),
      _freeBadge(
        id: 'long_letter',
        emoji: '💌',
        title: 'Uzun Mektup',
        condition: stats.hasLongEntry,
        unlockedDescription: '200 kelimelik bir yazı yazdın.',
        lockedDescription: '200 kelimelik bir yazıyla açılacak.',
      ),
      _freeBadge(
        id: 'writer_of_the_week',
        emoji: '🏅',
        title: 'Haftanın Yazarı',
        condition: stats.maxWeeklyEntryCount >= 3,
        unlockedDescription: 'Aynı haftada üç yazı yazdın.',
        lockedDescription: 'Bir haftada 3 yazı yazınca açılacak.',
      ),
      _premiumBadge(
        id: 'ten_entry_writer',
        emoji: '📚',
        title: 'On Günlük Yazar',
        condition: stats.totalEntries >= 10,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'On yazı biriktirdin.',
      ),
      _premiumBadge(
        id: 'twenty_entry_writer',
        emoji: '📖',
        title: 'Yirmi Günlük Yazar',
        condition: stats.totalEntries >= 20,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Yirmi yazı biriktirdin.',
      ),
      _premiumBadge(
        id: 'thirty_entry_writer',
        emoji: '🏆',
        title: 'Otuz Günlük Yazar',
        condition: stats.totalEntries >= 30,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Otuz yazı biriktirdin.',
      ),
      _premiumBadge(
        id: 'word_garden',
        emoji: '🌷',
        title: 'Kelime Bahçesi',
        condition: stats.totalWords >= 500,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Toplam 500 kelime yazdın.',
      ),
      _premiumBadge(
        id: 'word_forest',
        emoji: '🌳',
        title: 'Kelime Ormanı',
        condition: stats.totalWords >= 1000,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Toplam 1000 kelime yazdın.',
      ),
      _premiumBadge(
        id: 'emotion_explorer',
        emoji: '🧭',
        title: 'Duygu Kaşifi',
        condition: stats.distinctMoodCount >= 5,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Beş farklı duyguyla yazdın.',
      ),
      _premiumBadge(
        id: 'regular_writer',
        emoji: '🔥',
        title: 'Düzenli Yazar',
        condition: streakStats.bestStreak >= 3,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: '3 gün üst üste yazdın.',
      ),
      _premiumBadge(
        id: 'strong_habit',
        emoji: '💪',
        title: 'Güçlü Alışkanlık',
        condition: streakStats.bestStreak >= 5,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: '5 gün üst üste yazdın.',
      ),
      _premiumBadge(
        id: 'great_streak',
        emoji: '⭐',
        title: 'Harika Seri',
        condition: streakStats.bestStreak >= 7,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: '7 gün üst üste yazdın.',
      ),
      _premiumBadge(
        id: 'weekly_hero',
        emoji: '🦸',
        title: 'Haftalık Kahraman',
        condition: stats.maxWeeklyEntryCount >= 5,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Bir haftada beş yazı yazdın.',
      ),
      _premiumBadge(
        id: 'book_preparer',
        emoji: '📔',
        title: 'Kitap Hazırlayıcı',
        condition: activityStats.hasOpenedBook,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Günlük Kitabım ekranını açtın.',
      ),
      _premiumBadge(
        id: 'book_author',
        emoji: '📕',
        title: 'Kitap Yazarı',
        condition: activityStats.hasPreviewedPdf,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'PDF Günlük Kitabını önizledin.',
      ),
      _premiumBadge(
        id: 'titled_entries',
        emoji: '🏷️',
        title: 'Başlıklı Yazılar',
        condition: stats.titledEntryCount >= 5,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Beş yazına başlık ekledin.',
      ),
      _premiumBadge(
        id: 'little_storyteller',
        emoji: '🪶',
        title: 'Minik Hikâyeci',
        condition: stats.longEntryCount >= 3,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Üç uzun yazı yazdın.',
      ),
      _premiumBadge(
        id: 'emotion_diary_master',
        emoji: '🎭',
        title: 'Duygu Günlüğü Ustası',
        condition:
            stats.distinctMoodCount >= 3 && stats.moodDayVarietyCount >= 5,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: 'Farklı günlerde farklı duygularla yazdın.',
      ),
      _premiumBadge(
        id: 'gunbi_friend',
        emoji: '🤝',
        title: "Günbi'nin Dostu",
        condition: activityStats.coachHelpCount >= 3,
        isPremiumUnlocked: isPremiumUnlocked,
        unlockedDescription: "Günbi'den birkaç kez yardım aldın.",
      ),
    ];
  }

  List<Badge> newlyUnlocked({
    required JournalStats before,
    required JournalStats after,
    StreakStats beforeStreak = const StreakStats.empty(),
    StreakStats afterStreak = const StreakStats.empty(),
    RewardActivityStats activityStats = const RewardActivityStats.empty(),
    bool isPremiumUnlocked = false,
  }) {
    final beforeUnlockedIds = evaluate(
      before,
      streakStats: beforeStreak,
      activityStats: activityStats,
      isPremiumUnlocked: isPremiumUnlocked,
    ).where((badge) => badge.isUnlocked).map((badge) => badge.id).toSet();

    return evaluate(
          after,
          streakStats: afterStreak,
          activityStats: activityStats,
          isPremiumUnlocked: isPremiumUnlocked,
        )
        .where((badge) => badge.isUnlocked)
        .where((badge) => !beforeUnlockedIds.contains(badge.id))
        .take(2)
        .toList();
  }

  Badge _freeBadge({
    required String id,
    required String emoji,
    required String title,
    required bool condition,
    required String unlockedDescription,
    required String lockedDescription,
  }) {
    return Badge(
      id: id,
      emoji: emoji,
      title: title,
      description: condition ? unlockedDescription : lockedDescription,
      isUnlocked: condition,
    );
  }

  Badge _premiumBadge({
    required String id,
    required String emoji,
    required String title,
    required bool condition,
    required bool isPremiumUnlocked,
    required String unlockedDescription,
  }) {
    final isUnlocked = isPremiumUnlocked && condition;
    return Badge(
      id: id,
      emoji: emoji,
      title: title,
      description: isUnlocked
          ? unlockedDescription
          : isPremiumUnlocked
          ? 'Biraz daha yazınca açılacak.'
          : 'Bu rozet Premium ile açılır. Bir ebeveynden yardım isteyebilirsin.',
      isUnlocked: isUnlocked,
      isPremium: true,
    );
  }
}
