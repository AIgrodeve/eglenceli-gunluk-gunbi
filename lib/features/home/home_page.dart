import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/journal_entries_page.dart';
import '../journal/mood_selection_page.dart';
import '../parent/parent_page.dart';
import '../rewards/models/journal_stats.dart';
import '../rewards/rewards_page.dart';
import '../settings/settings_page.dart';
import '../streak/models/streak_stats.dart';
import '../streak/services/streak_service.dart';
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
  final StreakService _streakService = const StreakService();
  late Future<(JournalStats, StreakStats)> _dashboardFuture;
  late String _childName;
  late AgeGroup _ageGroup;

  @override
  void initState() {
    super.initState();
    _childName = widget.childName;
    _ageGroup = widget.ageGroup ?? AgeGroup.sixToEight;
    _dashboardFuture = _loadDashboardStats();
  }

  Future<(JournalStats, StreakStats)> _loadDashboardStats() async {
    final entries = await _repository.loadEntries();
    return (
      JournalStats.fromEntries(entries),
      _streakService.calculate(entries),
    );
  }

  void _refreshStats() {
    setState(() => _dashboardFuture = _loadDashboardStats());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Eğlenceli Günlük')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Merhaba, $_childName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${_ageGroup.label} yazı yolculuğu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _GunbiPromptCard(dashboardFuture: _dashboardFuture),
            const SizedBox(height: 12),
            _StreakCard(dashboardFuture: _dashboardFuture),
            const SizedBox(height: 24),
            _HomeActionGrid(
              actions: [
                _HomeAction(
                  icon: Icons.edit_note_rounded,
                  label: 'Bugün yaz',
                  onPressed: () => _openAndRefresh(
                    MoodSelectionPage(
                      childName: _childName,
                      ageGroup: _ageGroup,
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
                      childName: _childName,
                      ageGroup: _ageGroup,
                    ),
                  ),
                ),
                _HomeAction(
                  icon: Icons.family_restroom_rounded,
                  label: 'Ebeveyn Alanı',
                  onPressed: () => _openAndRefresh(
                    ParentPage(childName: _childName, ageGroup: _ageGroup),
                  ),
                ),
                _HomeAction(
                  icon: Icons.settings_rounded,
                  label: 'Ayarlar',
                  onPressed: _openSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push<SettingsResult>(
      MaterialPageRoute<SettingsResult>(
        builder: (_) =>
            SettingsPage(childName: _childName, ageGroup: _ageGroup),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      setState(() {
        _childName = result.childName;
        _ageGroup = result.ageGroup;
        _dashboardFuture = _loadDashboardStats();
      });
    } else {
      _refreshStats();
    }
  }
}

class _GunbiPromptCard extends StatelessWidget {
  const _GunbiPromptCard({required this.dashboardFuture});

  final Future<(JournalStats, StreakStats)> dashboardFuture;

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
              future: dashboardFuture.then((value) => value.$1),
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

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.dashboardFuture});

  final Future<(JournalStats, StreakStats)> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(JournalStats, StreakStats)>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        final streakStats = snapshot.data?.$2 ?? const StreakStats.empty();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.lightOrange, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yazı Serin', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _streakMessage(streakStats),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _MiniStreakInfo(
                    text: 'En iyi seri: ${streakStats.bestStreak} gün',
                  ),
                  _MiniStreakInfo(
                    text:
                        'Yazı yazdığın gün sayısı: ${streakStats.totalWrittenDays}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _streakMessage(StreakStats streakStats) {
    if (!streakStats.hasAnyEntry) {
      return 'İlk yazını yazınca serin başlayacak.';
    }
    if (streakStats.hasWrittenToday && streakStats.currentStreak >= 3) {
      return 'Üst üste ${streakStats.currentStreak} gün yazdın. Harika gidiyorsun!';
    }
    if (streakStats.hasWrittenToday && streakStats.currentStreak == 1) {
      return 'Güzel başlangıç! Bugün yazı yolculuğun başladı.';
    }
    if (streakStats.hasWrittenToday) {
      return 'Bugün yazdın! Günbi çok sevindi.';
    }
    if (streakStats.currentStreak >= 3) {
      return 'Üst üste ${streakStats.currentStreak} gün yazdın. Harika gidiyorsun!';
    }
    if (streakStats.hasWrittenYesterday) {
      return 'Günbi bugün de seni bekliyor. Küçük bir yazı yeter.';
    }
    return 'Olur, bazen ara vermek de gerekir. Bugün yeni bir başlangıç yapabiliriz.';
  }
}

class _MiniStreakInfo extends StatelessWidget {
  const _MiniStreakInfo({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.pastelYellow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
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
