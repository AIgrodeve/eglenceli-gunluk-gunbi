import 'package:flutter/material.dart' hide Badge;

import '../../core/theme/app_theme.dart';
import '../journal/data/journal_repository.dart';
import 'models/badge.dart';
import 'models/journal_stats.dart';
import 'services/badge_service.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const repository = JournalRepository();
    const badgeService = BadgeService();

    return Scaffold(
      appBar: AppBar(title: const Text('Rozetlerim')),
      body: SafeArea(
        child: FutureBuilder<List<Badge>>(
          future: repository.loadEntries().then(
            (entries) =>
                badgeService.evaluate(JournalStats.fromEntries(entries)),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final badges = snapshot.data ?? const <Badge>[];
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                return _BadgeCard(badge: badges[index]);
              },
            );
          },
        ),
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

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isUnlocked ? 1 : 0.48,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isUnlocked ? badge.emoji : '🔒',
                style: const TextStyle(fontSize: 42),
              ),
              const SizedBox(height: 10),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                isUnlocked ? badge.description : 'Biraz daha yazınca açılacak.',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
