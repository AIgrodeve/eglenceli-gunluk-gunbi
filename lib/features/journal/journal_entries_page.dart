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
  });

  final bool showSavedMessage;
  final List<reward_badge.Badge> newlyUnlockedBadges;

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

        if (widget.newlyUnlockedBadges.isEmpty) {
          return;
        }

        await Future<void>.delayed(const Duration(milliseconds: 1400));
        if (!mounted) {
          return;
        }

        final badgeText = widget.newlyUnlockedBadges
            .map((badge) => '${badge.emoji} ${badge.title}')
            .join(', ');
        final message = widget.newlyUnlockedBadges.length == 1
            ? 'Yeni bir rozet kazandın: $badgeText'
            : 'Yeni rozetler kazandın: $badgeText';

        messenger.showSnackBar(SnackBar(content: Text(message)));
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
                    _formatDate(entry.createdAt),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${entry.moodEmoji} ${entry.moodLabel}',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
