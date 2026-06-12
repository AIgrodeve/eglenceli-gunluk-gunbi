import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/journal_entries_page.dart';
import '../journal/mood_selection_page.dart';
import '../rewards/rewards_page.dart';
import 'gunbi_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eğlenceli Günlük')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Merhaba, $childName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            const _GunbiPromptCard(),
            const SizedBox(height: 24),
            _HomeActionButton(
              icon: Icons.edit_note_rounded,
              label: 'Bugün yaz',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MoodSelectionPage(childName: childName),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeActionButton(
              icon: Icons.article_rounded,
              label: 'Yazılarım',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const JournalEntriesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeActionButton(
              icon: Icons.workspace_premium_rounded,
              label: 'Rozetlerim',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RewardsPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeActionButton(
              icon: Icons.wb_sunny_rounded,
              label: 'Günbi',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const GunbiPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GunbiPromptCard extends StatelessWidget {
  const _GunbiPromptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Row(
        children: [
          const MascotWidget(size: 78),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Günbi bugün de yazmanı bekliyor.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
