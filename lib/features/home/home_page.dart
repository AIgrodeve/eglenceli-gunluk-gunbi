import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/journal_entries_page.dart';
import '../journal/mood_selection_page.dart';
import '../rewards/models/journal_stats.dart';
import '../rewards/rewards_page.dart';
import '../weekly_summary/weekly_summary_page.dart';
import 'gunbi_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childName, this.ageGroup});

  final String childName;
  final AgeGroup? ageGroup;

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

  Future<void> _openAndRefresh(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) {
      _refreshStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageGroup = widget.ageGroup ?? AgeGroup.sixToEight;

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
            const SizedBox(height: 6),
            Text(
              '${ageGroup.label} yazı yolculuğu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _GunbiPromptCard(statsFuture: _statsFuture),
            const SizedBox(height: 24),
            _HomeActionGrid(
              actions: [
                _HomeAction(
                  icon: Icons.edit_note_rounded,
                  label: 'Bugün yaz',
                  onPressed: () => _openAndRefresh(
                    MoodSelectionPage(
                      childName: widget.childName,
                      ageGroup: ageGroup,
                    ),
                  ),
                ),
                _HomeAction(
                  icon: Icons.article_rounded,
                  label: 'Yazılarım',
                  onPressed: () => _openAndRefresh(const JournalEntriesPage()),
                ),
                _HomeAction(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Rozetlerim',
                  onPressed: () => _openAndRefresh(const RewardsPage()),
                ),
                _HomeAction(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Günbi',
                  onPressed: () => _openAndRefresh(const GunbiPage()),
                ),
                _HomeAction(
                  icon: Icons.calendar_month_rounded,
                  label: 'Haftalık Özet',
                  onPressed: () => _openAndRefresh(
                    WeeklySummaryPage(
                      childName: widget.childName,
                      ageGroup: ageGroup,
                    ),
                  ),
                ),
              ],
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

class _HomeActionGrid extends StatelessWidget {
  const _HomeActionGrid({required this.actions});

  final List<_HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                height: 112,
                child: _HomeActionCard(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: AppTheme.cocoa, size: 30),
              const SizedBox(height: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
