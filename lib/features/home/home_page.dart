import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/journal_entries_page.dart';
import '../journal/mood_selection_page.dart';
import '../rewards/models/journal_stats.dart';
import '../rewards/rewards_page.dart';
import 'gunbi_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childName});

  final String childName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final JournalRepository _repository = const JournalRepository();
  late Future<JournalStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<JournalStats> _loadStats() async {
    final entries = await _repository.loadEntries();
    return JournalStats.fromEntries(entries);
  }

  void _refreshStats() {
    setState(() => _statsFuture = _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eğlenceli Günlük')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Merhaba, ${widget.childName}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            _GunbiPromptCard(statsFuture: _statsFuture),
            const SizedBox(height: 24),
            _HomeActionButton(
              icon: Icons.edit_note_rounded,
              label: 'Bugün yaz',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        MoodSelectionPage(childName: widget.childName),
                  ),
                );
                if (mounted) {
                  _refreshStats();
                }
              },
            ),
            const SizedBox(height: 12),
            _HomeActionButton(
              icon: Icons.article_rounded,
              label: 'Yazılarım',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const JournalEntriesPage(),
                  ),
                );
                if (mounted) {
                  _refreshStats();
                }
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
  const _GunbiPromptCard({required this.statsFuture});

  final Future<JournalStats> statsFuture;

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
            child: FutureBuilder<JournalStats>(
              future: statsFuture,
              builder: (context, snapshot) {
                final totalEntries = snapshot.data?.totalEntries ?? 0;
                final message = totalEntries == 0
                    ? 'Günbi ilk yazını bekliyor.'
                    : 'Bugüne kadar $totalEntries yazı yazdın.';

                return Text(
                  message,
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
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
