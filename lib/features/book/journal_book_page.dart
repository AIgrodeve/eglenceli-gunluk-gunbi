import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/data/app_preferences.dart';
import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../journal/models/journal_entry.dart';
import '../journal/mood_selection_page.dart';
import '../rewards/models/journal_stats.dart';
import '../streak/services/streak_service.dart';
import 'services/journal_book_pdf_service.dart';

class JournalBookPage extends StatefulWidget {
  const JournalBookPage({
    super.key,
    required this.childName,
    required this.ageGroup,
  });

  final String childName;
  final AgeGroup ageGroup;

  @override
  State<JournalBookPage> createState() => _JournalBookPageState();
}

class _JournalBookPageState extends State<JournalBookPage> {
  final AppPreferences _preferences = const AppPreferences();
  final JournalRepository _repository = const JournalRepository();
  final JournalBookPdfService _pdfService = const JournalBookPdfService();
  final StreakService _streakService = const StreakService();
  late final TextEditingController _titleController;
  late Future<_BookPreviewData> _previewFuture;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _defaultTitle);
    _previewFuture = _loadPreview();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<_BookPreviewData> _loadPreview() async {
    final savedTitle = await _preferences.loadBookTitle();
    final entries = await _repository.loadEntries();
    final sortedEntries = [...entries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final stats = JournalStats.fromEntries(entries);
    final streakStats = _streakService.calculate(entries);

    final title = savedTitle ?? _defaultTitle;
    _titleController.text = title;

    return _BookPreviewData(
      title: title,
      entries: sortedEntries,
      stats: stats,
      bestStreak: streakStats.bestStreak,
      mostFrequentMood: _mostFrequentMood(entries),
      firstEntryDate: sortedEntries.isEmpty
          ? null
          : sortedEntries.first.createdAt,
      lastEntryDate: sortedEntries.isEmpty
          ? null
          : sortedEntries.last.createdAt,
      writtenDayCount: streakStats.totalWrittenDays,
    );
  }

  Future<void> _saveTitle(String value) async {
    final title = value.trim().isEmpty ? _defaultTitle : value.trim();
    _titleController.text = title;
    await _preferences.updateBookTitle(title);
  }

  Future<void> _previewPdf(_BookPreviewData preview) async {
    if (preview.entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF için önce günlüğüne birkaç yazı ekleyelim.'),
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _defaultTitle
        : _titleController.text.trim();
    await _preferences.updateBookTitle(title);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günbi kitabını hazırlıyor...')),
        );
      }

      await Printing.layoutPdf(
        name: _pdfService.safeFileName(childName: widget.childName),
        onLayout: (_) => _pdfService.buildPdf(
          bookTitle: title,
          childName: widget.childName,
          ageGroup: widget.ageGroup,
          entries: preview.entries,
          stats: preview.stats,
          writtenDayCount: preview.writtenDayCount,
          mostFrequentMood: preview.mostFrequentMood,
          bestStreak: preview.bestStreak,
          firstEntryDate: preview.firstEntryDate,
          lastEntryDate: preview.lastEntryDate,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Günbi kitabı hazırlarken biraz zorlandı. Tekrar deneyelim.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Kitabım')),
      body: SafeArea(
        child: FutureBuilder<_BookPreviewData>(
          future: _previewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final preview =
                snapshot.data ?? _BookPreviewData.empty(_defaultTitle);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: MascotWidget(size: 118, mood: MascotMood.excited),
                ),
                const SizedBox(height: 18),
                Text(
                  'Yazıların bir gün güzel bir kitaba dönüşebilir!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Her yazı kitabına küçük bir sayfa ekliyor.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                _TitleCard(
                  controller: _titleController,
                  onSubmitted: _saveTitle,
                ),
                const SizedBox(height: 16),
                if (preview.entries.isEmpty)
                  _EmptyBookState(
                    onWriteToday: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MoodSelectionPage(
                            childName: widget.childName,
                            ageGroup: widget.ageGroup,
                          ),
                        ),
                      );
                    },
                  )
                else ...[
                  _BookStatsGrid(preview: preview),
                  const SizedBox(height: 18),
                  Text(
                    'Kitaba Girecek Yazılar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final entry in preview.entries) ...[
                    _BookEntryCard(entry: entry),
                    const SizedBox(height: 12),
                  ],
                ],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _previewPdf(preview),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('PDF Önizle'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String get _defaultTitle {
    final childName = widget.childName.trim();
    if (childName.isEmpty) {
      return 'Benim Eğlenceli Günlüğüm';
    }
    return "$childName'in Eğlenceli Günlüğü";
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
    for (final mood in counts.entries) {
      if (mood.value > bestCount) {
        bestMood = mood.key;
        bestCount = mood.value;
      }
    }

    return '${emojis[bestMood] ?? ''} $bestMood'.trim();
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return _BookCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kitap başlığı', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            onSubmitted: onSubmitted,
            onEditingComplete: () => onSubmitted(controller.text),
            decoration: const InputDecoration(hintText: 'Kitap başlığı'),
          ),
        ],
      ),
    );
  }
}

class _BookStatsGrid extends StatelessWidget {
  const _BookStatsGrid({required this.preview});

  final _BookPreviewData preview;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Toplam yazı', '${preview.stats.totalEntries}'),
      _StatItem('Toplam kelime', '${preview.stats.totalWords}'),
      _StatItem('Yazılan gün', '${preview.writtenDayCount}'),
      _StatItem('En sık duygu', preview.mostFrequentMood),
      _StatItem('En iyi seri', '${preview.bestStreak} gün'),
      _StatItem('İlk yazı', _formatDate(preview.firstEntryDate)),
      _StatItem('Son yazı', _formatDate(preview.lastEntryDate)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _StatCard(item: item),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Henüz yok';
    }
    final localDate = dateTime.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    return '$day.$month.${localDate.year}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
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
          Text(item.label, style: Theme.of(context).textTheme.bodyMedium),
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

class _BookEntryCard extends StatelessWidget {
  const _BookEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return _BookCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(entry.createdAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _entryTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text('${entry.moodEmoji} ${entry.moodLabel}'),
          if (entry.promptText != null &&
              entry.promptText!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Konu: ${entry.promptText}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            entry.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  String get _entryTitle {
    final title = entry.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return 'Günlük Yazım';
  }

  String _formatDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    return '$day.$month.$year';
  }
}

class _EmptyBookState extends StatelessWidget {
  const _EmptyBookState({required this.onWriteToday});

  final VoidCallback onWriteToday;

  @override
  Widget build(BuildContext context) {
    return _BookCard(
      child: Column(
        children: [
          Text(
            'Kitabın için henüz yazı yok. İlk yazını ekleyince burada görünmeye başlayacak.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onWriteToday,
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Bugünü yaz'),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: child,
    );
  }
}

class _BookPreviewData {
  const _BookPreviewData({
    required this.title,
    required this.entries,
    required this.stats,
    required this.bestStreak,
    required this.mostFrequentMood,
    required this.firstEntryDate,
    required this.lastEntryDate,
    required this.writtenDayCount,
  });

  factory _BookPreviewData.empty(String title) {
    return _BookPreviewData(
      title: title,
      entries: const [],
      stats: JournalStats.fromEntries(const []),
      bestStreak: 0,
      mostFrequentMood: 'Henüz yok',
      firstEntryDate: null,
      lastEntryDate: null,
      writtenDayCount: 0,
    );
  }

  final String title;
  final List<JournalEntry> entries;
  final JournalStats stats;
  final int bestStreak;
  final String mostFrequentMood;
  final DateTime? firstEntryDate;
  final DateTime? lastEntryDate;
  final int writtenDayCount;
}

class _StatItem {
  const _StatItem(this.label, this.value);

  final String label;
  final String value;
}
