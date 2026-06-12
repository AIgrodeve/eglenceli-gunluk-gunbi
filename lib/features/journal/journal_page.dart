import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'data/journal_repository.dart';
import 'journal_entries_page.dart';
import 'models/journal_entry.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({
    super.key,
    required this.childName,
    required this.moodLabel,
    required this.moodEmoji,
  });

  final String childName;
  final String moodLabel;
  final String moodEmoji;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _textController = TextEditingController();
  final JournalRepository _repository = const JournalRepository();

  bool _isSaving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

    final entry = JournalEntry.create(
      childName: widget.childName,
      moodLabel: widget.moodLabel,
      moodEmoji: widget.moodEmoji,
      text: text,
    );
    await _repository.addEntry(entry);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const JournalEntriesPage(showSavedMessage: true),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _textController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Bugün neler oldu?',
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
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveEntry,
                icon: const Icon(Icons.favorite_rounded),
                label: Text(_isSaving ? 'Kaydediliyor...' : 'Günlüğüme ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
