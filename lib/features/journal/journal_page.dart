import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import 'data/journal_repository.dart';
import 'journal_entries_page.dart';
import 'models/journal_entry.dart';
import 'services/writing_coach_service.dart';
import 'services/writing_prompt_service.dart';
import '../rewards/models/journal_stats.dart';
import '../rewards/services/badge_service.dart';
import '../streak/services/streak_service.dart';
import '../premium/premium_page.dart';
import '../premium/services/premium_service.dart';

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
  final StreakService _streakService = const StreakService();
  final PremiumService _premiumService = const PremiumService();
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

    final previousEntries = await _repository.loadEntries();
    final isPremiumUnlocked = await _premiumService.isPremiumUnlocked();
    if (!mounted) {
      return;
    }

    if (!isPremiumUnlocked &&
        previousEntries.length >= PremiumService.freeEntryLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Harika bir yazı alışkanlığı oluşturdun! Daha fazla yazı eklemek için bir ebeveynden yardım isteyebilirsin.',
          ),
          action: SnackBarAction(
            label: 'Ebeveyne göster',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PremiumPage()),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final previousStats = JournalStats.fromEntries(previousEntries);
    final previousStreak = _streakService.calculate(previousEntries);
    final entry = JournalEntry.create(
      childName: widget.childName,
      moodLabel: widget.moodLabel,
      moodEmoji: widget.moodEmoji,
      text: text,
      title: _titleController.text.trim(),
      promptText: _promptText,
    );
    await _repository.addEntry(entry);
    final newEntries = [entry, ...previousEntries];
    final newStats = JournalStats.fromEntries(newEntries);
    final newStreak = _streakService.calculate(newEntries);
    final newlyUnlockedBadges = _badgeService.newlyUnlocked(
      before: previousStats,
      after: newStats,
      beforeStreak: previousStreak,
      afterStreak: newStreak,
    );
    final streakMessages = _newStreakMessages(
      previousStreak.currentStreak,
      newStreak.currentStreak,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => JournalEntriesPage(
          showSavedMessage: true,
          newlyUnlockedBadges: newlyUnlockedBadges,
          streakMessages: streakMessages,
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
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
            const _WritingMascotCard(),
            const SizedBox(height: 14),
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
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _titleHintText,
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
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: TextField(
                controller: _textController,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
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
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _showCoachSuggestions,
              icon: const Icon(Icons.lightbulb_rounded),
              label: const Text("Günbi'den yardım al"),
            ),
            if (_coachSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _CoachSuggestionsPanel(suggestions: _coachSuggestions),
            ],
            const SizedBox(height: 18),
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

  List<String> _newStreakMessages(int previousStreak, int newStreak) {
    if (previousStreak < 3 && newStreak >= 3) {
      return const ['🔥 Üst üste 3 gün! Harika gidiyorsun!'];
    }
    if (previousStreak < 7 && newStreak >= 7) {
      return const ['⭐ Bir hafta! Sen artık gerçek bir yazar gibisin!'];
    }
    if (previousStreak < 30 && newStreak >= 30) {
      return const ["👑 30 gün! Günbi'nin en yakın yazı arkadaşısın!"];
    }
    return const [];
  }
}

class _WritingMascotCard extends StatelessWidget {
  const _WritingMascotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.softBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.softBlue.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          const MascotWidget(
            size: 72,
            mood: MascotMood.writing,
            showShadow: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Günbi yazmaya hazır. Küçük bir cümle bile güzel bir başlangıç.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingPromptCard extends StatelessWidget {
  const _WritingPromptCard({required this.promptText, required this.onRefresh});

  final String promptText;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
        color: AppTheme.pastelYellow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightOrange.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppTheme.lightOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Günbi diyor ki:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final suggestion in suggestions) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppTheme.lightOrange,
                  ),
                ),
                const SizedBox(width: 8),
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
