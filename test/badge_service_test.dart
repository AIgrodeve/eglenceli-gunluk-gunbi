import 'package:eglenceli_gunluk_gunbi/features/journal/models/journal_entry.dart';
import 'package:eglenceli_gunluk_gunbi/features/rewards/models/badge.dart';
import 'package:eglenceli_gunluk_gunbi/features/rewards/models/journal_stats.dart';
import 'package:eglenceli_gunluk_gunbi/features/rewards/models/reward_activity_stats.dart';
import 'package:eglenceli_gunluk_gunbi/features/rewards/services/badge_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/streak/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badgeService = BadgeService();
  const streakService = StreakService();

  test('badge catalog contains 8 free and 16 premium badges', () {
    final badges = badgeService.evaluate(JournalStats.fromEntries(const []));

    expect(badges, hasLength(24));
    expect(badges.where((badge) => !badge.isPremium), hasLength(8));
    expect(badges.where((badge) => badge.isPremium), hasLength(16));
  });

  test('premium badges stay locked until premium is unlocked', () {
    final entries = _entries(count: 10);
    final stats = JournalStats.fromEntries(entries);
    final streakStats = streakService.calculate(
      entries,
      now: DateTime(2026, 6, 18, 12),
    );
    const activityStats = RewardActivityStats(
      hasOpenedBook: true,
      hasPreviewedPdf: true,
      coachHelpCount: 3,
    );

    final freeState = badgeService.evaluate(
      stats,
      streakStats: streakStats,
      activityStats: activityStats,
    );
    final premiumState = badgeService.evaluate(
      stats,
      streakStats: streakStats,
      activityStats: activityStats,
      isPremiumUnlocked: true,
    );

    expect(
      freeState.where((badge) => badge.isPremium),
      everyElement(predicate<Badge>((badge) => !badge.isUnlocked)),
    );
    expect(
      premiumState
          .firstWhere((badge) => badge.id == 'ten_entry_writer')
          .isUnlocked,
      isTrue,
    );
    expect(
      premiumState
          .firstWhere((badge) => badge.id == 'book_preparer')
          .isUnlocked,
      isTrue,
    );
    expect(
      premiumState.firstWhere((badge) => badge.id == 'book_author').isUnlocked,
      isTrue,
    );
    expect(
      premiumState.firstWhere((badge) => badge.id == 'gunbi_friend').isUnlocked,
      isTrue,
    );
  });
}

List<JournalEntry> _entries({required int count}) {
  return List.generate(count, (index) {
    final day = DateTime(2026, 6, 18).subtract(Duration(days: index));
    return JournalEntry(
      id: 'entry_$index',
      childName: 'Meryem',
      moodLabel: index.isEven ? 'Mutlu' : 'Sakin',
      moodEmoji: index.isEven ? '😊' : '😌',
      text: 'Bugün yazı yazdım ve duygularımı anlattım.',
      createdAt: day.add(const Duration(hours: 9)),
      title: 'Başlık $index',
    );
  });
}
