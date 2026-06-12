import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'data/journal_repository.dart';
import 'models/journal_entry.dart';
import '../rewards/models/badge.dart' as reward_badge;

class JournalEntriesPage extends StatefulWidget {
  const JournalEntriesPage({
    super.key,
    this.showSavedMessage = false,
    this.newlyUnlockedBadges = const [],
    this.streakMessages = const [],
  });

  final bool showSavedMessage;
  final List<reward_badge.Badge> newlyUnlockedBadges;
  final List<String> streakMessages;

  @override
  State<JournalEntriesPage> createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends State<JournalEntriesPage> {
  bool _didShowSavedMessage = false;

  @override
  Widget build(BuildContext context) {
    const repository = JournalRepository();

    if (widget.showSavedMessage && !_didShowSavedMessage) {
      _didShowSavedMessage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Harika! Günlüğüne yeni bir yazı ekledik.'),
          ),
        );

        final followUpMessages = [
          ...widget.streakMessages,
          if (widget.newlyUnlockedBadges.isNotEmpty)
            widget.newlyUnlockedBadges.length == 1
                ? 'Yeni bir rozet kazandın: ${_badgeText(widget.newlyUnlockedBadges)}'
                : 'Yeni rozetler kazandın: ${_badgeText(widget.newlyUnlockedBadges)}',
        ];

        if (followUpMessages.isEmpty) {
          return;
        }

        await Future<void>.delayed(const Duration(milliseconds: 1400));
        if (!mounted) {
          return;
        }

        messenger.showSnackBar(SnackBar(content: Text(followUpMessages.first)));
        if (followUpMessages.length < 2) {
          return;
        }

        await Future<void>.delayed(const Duration(milliseconds: 1400));
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(SnackBar(content: Text(followUpMessages[1])));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Yazılarım')),
      body: SafeArea(
        child: FutureBuilder<List<JournalEntry>>(
          future: repository.loadEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data ?? [];
            if (entries.isEmpty) {
              return const _EmptyEntries();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _JournalEntryCard(entry: entries[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

String _badgeText(List<reward_badge.Badge> badges) {
  return badges.map((badge) => '${badge.emoji} ${badge.title}').join(', ');
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _cardTitle(entry),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entry.moodEmoji} ${entry.moodLabel}',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            if (entry.title != null && entry.title!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_formatDate(entry.createdAt), style: textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            if (entry.promptText != null &&
                entry.promptText!.trim().isNotEmpty) ...[
              Text(
                'Konu: ${entry.promptText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              entry.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _cardTitle(JournalEntry entry) {
    final title = entry.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return _formatDate(entry.createdAt);
  }

  String _formatDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }
}

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Henüz günlüğüne bir yazı eklemedin. İlk yazını yazmaya ne dersin?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
