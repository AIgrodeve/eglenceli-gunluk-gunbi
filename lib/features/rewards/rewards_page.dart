import 'package:flutter/material.dart' hide Badge;

import '../../core/theme/app_theme.dart';
import '../journal/data/journal_repository.dart';
import '../premium/services/premium_service.dart';
import '../streak/services/streak_service.dart';
import 'models/badge.dart';
import 'models/journal_stats.dart';
import 'services/badge_service.dart';
import 'services/reward_activity_service.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rozetlerim')),
      body: SafeArea(
        child: FutureBuilder<_RewardsData>(
          future: _loadRewards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? const _RewardsData.empty();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BadgeSummary(data: data),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 218,
                  ),
                  itemBuilder: (context, index) {
                    return _BadgeCard(badge: data.badges[index]);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_RewardsData> _loadRewards() async {
    const repository = JournalRepository();
    const badgeService = BadgeService();
    const streakService = StreakService();
    const premiumService = PremiumService();
    const activityService = RewardActivityService();

    final entries = await repository.loadEntries();
    final isPremiumUnlocked = await premiumService.isPremiumUnlocked();
    final activityStats = await activityService.loadStats();
    final badges = badgeService.evaluate(
      JournalStats.fromEntries(entries),
      streakStats: streakService.calculate(entries),
      activityStats: activityStats,
      isPremiumUnlocked: isPremiumUnlocked,
    );

    return _RewardsData(badges: badges, isPremiumUnlocked: isPremiumUnlocked);
  }
}

class _BadgeSummary extends StatelessWidget {
  const _BadgeSummary({required this.data});

  final _RewardsData data;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = data.badges.where((badge) => badge.isUnlocked).length;
    final premiumCount = data.badges.where((badge) => badge.isPremium).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$unlockedCount / ${data.badges.length} rozet açıldı',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            data.isPremiumUnlocked
                ? '$premiumCount Premium rozet de gelişimine dahil.'
                : '$premiumCount Premium rozet seni bekliyor.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUnlocked = badge.isUnlocked;
    final isPremiumLocked = badge.isPremium && !isUnlocked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isUnlocked ? 1 : 0.62,
      child: Card(
        elevation: 0,
        color: isUnlocked ? Colors.white : AppTheme.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isUnlocked ? AppTheme.lightOrange : AppTheme.pastelYellow,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isPremiumLocked
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bu rozet Premium ile açılır. Bir ebeveynden yardım isteyebilirsin.',
                      ),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badge.isPremium) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Premium',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  isUnlocked ? badge.emoji : '🔒',
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(height: 7),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardsData {
  const _RewardsData({required this.badges, required this.isPremiumUnlocked});

  const _RewardsData.empty() : badges = const [], isPremiumUnlocked = false;

  final List<Badge> badges;
  final bool isPremiumUnlocked;
}
