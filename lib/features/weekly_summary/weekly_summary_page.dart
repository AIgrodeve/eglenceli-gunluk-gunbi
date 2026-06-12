import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/mood_selection_page.dart';
import 'models/weekly_summary.dart';
import 'services/weekly_summary_service.dart';

class WeeklySummaryPage extends StatelessWidget {
  const WeeklySummaryPage({super.key, required this.childName, this.ageGroup});

  final String childName;
  final AgeGroup? ageGroup;

  @override
  Widget build(BuildContext context) {
    const repository = JournalRepository();
    const summaryService = WeeklySummaryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Haftalık Özet')),
      body: SafeArea(
        child: FutureBuilder<WeeklySummary>(
          future: repository.loadEntries().then(summaryService.calculate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary = snapshot.data;
            if (summary == null || !summary.hasEntries) {
              return _EmptyWeeklySummary(
                childName: childName,
                ageGroup: ageGroup,
              );
            }

            return _WeeklySummaryContent(summary: summary);
          },
        ),
      ),
    );
  }
}

class _WeeklySummaryContent extends StatelessWidget {
  const _WeeklySummaryContent({required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: MascotWidget(size: 118, mood: MascotMood.proud)),
        const SizedBox(height: 18),
        Text(
          _gunbiMessage(summary),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          '${_formatDate(summary.weekStart)} - ${_formatDate(summary.weekEnd)}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _SummaryCard(
          icon: Icons.edit_note_rounded,
          title: 'Yazı sayısı',
          value: '${summary.entryCount}',
          message: 'Bu hafta ${summary.entryCount} kez yazdın!',
        ),
        _SummaryCard(
          icon: Icons.format_align_left_rounded,
          title: 'Kelime sayısı',
          value: '${summary.totalWordCount}',
          message: 'Toplam ${summary.totalWordCount} kelime biriktirdin.',
        ),
        _SummaryCard(
          icon: Icons.favorite_rounded,
          title: 'En sık duygu',
          value: summary.mostFrequentMoodText,
          message: 'En çok ${summary.mostFrequentMoodText} hissettin.',
        ),
        _SummaryCard(
          icon: Icons.auto_stories_rounded,
          title: 'En uzun yazı',
          value: '${summary.longestEntryWordCount}',
          message: 'En uzun yazın ${summary.longestEntryWordCount} kelimeydi.',
        ),
        _SummaryCard(
          icon: Icons.palette_rounded,
          title: 'Farklı duygu',
          value: '${summary.distinctMoodCount}',
          message: 'Bu hafta ${summary.distinctMoodCount} farklı duygu seçtin.',
        ),
        _SummaryCard(
          icon: Icons.local_fire_department_rounded,
          title: 'Yazdığın günler',
          value: '${summary.writtenDayCount}',
          message:
              'Bu hafta yazı yazdığın gün sayısı: ${summary.writtenDayCount}',
        ),
      ],
    );
  }

  String _gunbiMessage(WeeklySummary summary) {
    if (summary.entryCount >= 4) {
      return 'Bu hafta harika ilerledin!';
    }
    if (summary.totalWordCount < 50) {
      return 'Kısa yazılar da değerlidir.';
    }
    return 'Yazdıkça kelimelerin güçleniyor.';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day.$month.${dateTime.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.pastelYellow.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.cocoa),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWeeklySummary extends StatelessWidget {
  const _EmptyWeeklySummary({required this.childName, required this.ageGroup});

  final String childName;
  final AgeGroup? ageGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotWidget(size: 128, mood: MascotMood.calm),
            const SizedBox(height: 22),
            Text(
              'Bu hafta henüz yazı eklemedin. Günbi ilk yazını bekliyor!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MoodSelectionPage(
                      childName: childName,
                      ageGroup: ageGroup ?? AgeGroup.sixToEight,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Bugün yaz'),
            ),
          ],
        ),
      ),
    );
  }
}
