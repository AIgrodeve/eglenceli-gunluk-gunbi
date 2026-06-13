import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/adult_verification_dialog.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/models/journal_entry.dart';
import '../rewards/models/journal_stats.dart';
import '../streak/services/streak_service.dart';
import '../weekly_summary/services/weekly_summary_service.dart';

class ParentPage extends StatefulWidget {
  const ParentPage({
    super.key,
    required this.childName,
    required this.ageGroup,
  });

  final String childName;
  final AgeGroup ageGroup;

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  final JournalRepository _repository = const JournalRepository();
  final StreakService _streakService = const StreakService();
  final WeeklySummaryService _weeklySummaryService =
      const WeeklySummaryService();

  bool _isVerified = false;

  Future<void> _verifyAnswer() async {
    final verified = await showAdultVerificationDialog(
      context: context,
      title: 'Ebeveyn doğrulaması',
      question: 'Ebeveyn alanına geçmek için işlemi cevaplayın: 5 + 3 = ?',
      expectedAnswer: '8',
      wrongAnswerMessage: 'Bu alan ebeveynler içindir.',
    );
    if (!context.mounted) {
      return;
    }
    if (verified) {
      setState(() => _isVerified = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified) {
      return _ParentGate(onVerify: _verifyAnswer);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ebeveyn Alanı')),
      body: SafeArea(
        child: FutureBuilder<_ParentSummaryData>(
          future: _loadSummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary =
                snapshot.data ??
                _ParentSummaryData.empty(
                  childName: widget.childName,
                  ageGroup: widget.ageGroup,
                );

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: MascotWidget(
                    size: 96,
                    mood: MascotMood.calm,
                    showShadow: false,
                  ),
                ),
                const SizedBox(height: 16),
                const _InfoPanel(
                  title: 'Güvenli gelişim özeti',
                  message:
                      'Bu alan, çocuğun yazma alışkanlığını güvenli şekilde takip etmek için hazırlanmıştır.',
                ),
                const SizedBox(height: 12),
                const _InfoPanel(
                  title: 'Mahremiyet',
                  message:
                      'Günlük yazılar çocuğa özeldir. Burada sadece gelişim özeti gösterilir.',
                  isSoftBlue: true,
                ),
                const SizedBox(height: 18),
                if (summary.totalEntries == 0)
                  const _EmptyParentSummary()
                else
                  _SummaryGrid(summary: summary),
                const SizedBox(height: 18),
                const _SafetyPrinciples(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_ParentSummaryData> _loadSummary() async {
    final entries = await _repository.loadEntries();
    final journalStats = JournalStats.fromEntries(entries);
    final streakStats = _streakService.calculate(entries);
    final weeklySummary = _weeklySummaryService.calculate(entries);

    return _ParentSummaryData(
      childName: widget.childName,
      ageGroup: widget.ageGroup,
      totalEntries: journalStats.totalEntries,
      totalWords: journalStats.totalWords,
      totalWrittenDays: streakStats.totalWrittenDays,
      currentStreak: streakStats.currentStreak,
      bestStreak: streakStats.bestStreak,
      weeklyEntryCount: weeklySummary.entryCount,
      weeklyWrittenDayCount: weeklySummary.writtenDayCount,
      mostFrequentMood: _mostFrequentMood(entries),
    );
  }

  String _mostFrequentMood(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return 'Henüz yok';
    }

    final counts = <String, int>{};
    final emojis = <String, String>{};
    for (final entry in entries) {
      counts[entry.moodLabel] = (counts[entry.moodLabel] ?? 0) + 1;
      emojis[entry.moodLabel] = entry.moodEmoji;
    }

    var bestMood = counts.keys.first;
    var bestCount = counts[bestMood] ?? 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestMood = entry.key;
        bestCount = entry.value;
      }
    }

    return '${emojis[bestMood] ?? ''} $bestMood'.trim();
  }
}

class _ParentGate extends StatelessWidget {
  const _ParentGate({required this.onVerify});

  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ebeveyn Alanı')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ebeveyn alanına geçmek için kısa bir yetişkin doğrulaması yapalım.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Günlük içerikleri çocuğa özeldir; burada sadece gelişim özeti gösterilir.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onVerify,
                    child: const Text('Devam et'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.message,
    this.isSoftBlue = false,
  });

  final String title;
  final String message;
  final bool isSoftBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSoftBlue
            ? AppTheme.softBlue.withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSoftBlue ? AppTheme.softBlue : AppTheme.pastelYellow,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _EmptyParentSummary extends StatelessWidget {
  const _EmptyParentSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Text(
        'Henüz yazı eklenmemiş. İlk yazıdan sonra gelişim özeti burada görünecek.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final _ParentSummaryData summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryItem('Çocuk adı', summary.childName),
      _SummaryItem('Yaş grubu', summary.ageGroup.label),
      _SummaryItem('Toplam yazı', '${summary.totalEntries}'),
      _SummaryItem('Toplam kelime', '${summary.totalWords}'),
      _SummaryItem('Yazılan gün', '${summary.totalWrittenDays}'),
      _SummaryItem('Mevcut seri', '${summary.currentStreak} gün'),
      _SummaryItem('En iyi seri', '${summary.bestStreak} gün'),
      _SummaryItem('Bu hafta yazı', '${summary.weeklyEntryCount}'),
      _SummaryItem('Bu hafta gün', '${summary.weeklyWrittenDayCount}'),
      _SummaryItem('En sık duygu', summary.mostFrequentMood),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards)
              SizedBox(
                width: itemWidth,
                child: _SummaryCard(item: card),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _SafetyPrinciples extends StatelessWidget {
  const _SafetyPrinciples();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Herkese açık paylaşım yok.',
      'Çocuklar arası mesajlaşma yok.',
      'Konum izni kullanılmaz.',
      'Günlük yazıları cihazda saklanır.',
      'Yapay zekâ özelliği ileride eklenirse çocuk yerine yazmayacak, sadece rehberlik edecektir.',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik İlkeleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ParentSummaryData {
  const _ParentSummaryData({
    required this.childName,
    required this.ageGroup,
    required this.totalEntries,
    required this.totalWords,
    required this.totalWrittenDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyEntryCount,
    required this.weeklyWrittenDayCount,
    required this.mostFrequentMood,
  });

  factory _ParentSummaryData.empty({
    required String childName,
    required AgeGroup ageGroup,
  }) {
    return _ParentSummaryData(
      childName: childName,
      ageGroup: ageGroup,
      totalEntries: 0,
      totalWords: 0,
      totalWrittenDays: 0,
      currentStreak: 0,
      bestStreak: 0,
      weeklyEntryCount: 0,
      weeklyWrittenDayCount: 0,
      mostFrequentMood: 'Henüz yok',
    );
  }

  final String childName;
  final AgeGroup ageGroup;
  final int totalEntries;
  final int totalWords;
  final int totalWrittenDays;
  final int currentStreak;
  final int bestStreak;
  final int weeklyEntryCount;
  final int weeklyWrittenDayCount;
  final String mostFrequentMood;
}

class _SummaryItem {
  const _SummaryItem(this.label, this.value);

  final String label;
  final String value;
}
