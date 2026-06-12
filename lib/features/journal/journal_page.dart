import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import 'data/journal_repository.dart';
import 'journal_entries_page.dart';
import 'models/journal_entry.dart';
import 'services/writing_coach_service.dart';
import 'services/writing_prompt_service.dart';
import '../rewards/models/journal_stats.dart';
import '../rewards/services/badge_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({
    super.key,
    required this.childName,
    required this.ageGroup,
    required this.moodLabel,
    required this.moodEmoji,
  });

  final String childName;
  final AgeGroup ageGroup;
  final String moodLabel;
  final String moodEmoji;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final JournalRepository _repository = const JournalRepository();
  final BadgeService _badgeService = const BadgeService();
  final WritingCoachService _coachService = const WritingCoachService();
  final WritingPromptService _promptService = WritingPromptService();

  bool _isSaving = false;
  late String _promptText;
  List<String> _coachSuggestions = const [];

  @override
  void initState() {
    super.initState();
    _promptText = _promptService.randomPromptFor(widget.ageGroup);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _showCoachSuggestions() {
    setState(() {
      _coachSuggestions = _coachService.suggestionsFor(
        ageGroup: widget.ageGroup,
        text: _textController.text,
      );
    });
  }

  Future<void> _saveEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir kelime bile olur. Önce küçük bir şey yazalım mı?'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final previousEntries = await _repository.loadEntries();
    final previousStats = JournalStats.fromEntries(previousEntries);
    final entry = JournalEntry.create(
      childName: widget.childName,
      moodLabel: widget.moodLabel,
      moodEmoji: widget.moodEmoji,
      text: text,
      title: _titleController.text.trim(),
      promptText: _promptText,
    );
    await _repository.addEntry(entry);
    final newStats = JournalStats.fromEntries([entry, ...previousEntries]);
    final newlyUnlockedBadges = _badgeService.newlyUnlocked(
      before: previousStats,
      after: newStats,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => JournalEntriesPage(
          showSavedMessage: true,
          newlyUnlockedBadges: newlyUnlockedBadges,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.childName.isEmpty ? 'Yazar' : widget.childName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğlenceli Günlük'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const JournalEntriesPage(),
                ),
              );
            },
            tooltip: 'Yazılarım',
            icon: const Icon(Icons.article_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Hoş geldin, $displayName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bugün "${widget.moodEmoji} ${widget.moodLabel}" seçtin. İstersen gününü buraya anlat.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            _WritingPromptCard(
              promptText: _promptText,
              onRefresh: () {
                setState(() {
                  _promptText = _promptService.randomPromptFor(
                    widget.ageGroup,
                    except: _promptText,
                  );
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: _titleHintText),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              child: TextField(
                controller: _textController,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: _hintText,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppTheme.pastelYellow,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showCoachSuggestions,
              icon: const Icon(Icons.lightbulb_rounded),
              label: const Text("Günbi'den yardım al"),
            ),
            if (_coachSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _CoachSuggestionsPanel(suggestions: _coachSuggestions),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveEntry,
              icon: const Icon(Icons.favorite_rounded),
              label: Text(_isSaving ? 'Kaydediliyor...' : 'Günlüğüme ekle'),
            ),
          ],
        ),
      ),
    );
  }

  String get _hintText {
    return switch (widget.ageGroup) {
      AgeGroup.sixToEight => 'Birkaç cümle yazabilirsin...',
      AgeGroup.nineToEleven => 'Düşüncelerini burada anlatabilirsin...',
    };
  }

  String get _titleHintText {
    return switch (widget.ageGroup) {
      AgeGroup.sixToEight => 'Yazına küçük bir başlık...',
      AgeGroup.nineToEleven => 'Yazına bir başlık verebilirsin...',
    };
  }
}

class _WritingPromptCard extends StatelessWidget {
  const _WritingPromptCard({required this.promptText, required this.onRefresh});

  final String promptText;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugün bunu yazmayı deneyebilirsin:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            promptText,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Başka öneri'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachSuggestionsPanel extends StatelessWidget {
  const _CoachSuggestionsPanel({required this.suggestions});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pastelYellow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günbi diyor ki:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final suggestion in suggestions) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    suggestion,
                    style: Theme.of(context).textTheme.bodyLarge,
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
