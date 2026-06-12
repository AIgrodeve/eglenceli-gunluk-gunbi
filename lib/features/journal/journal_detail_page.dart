import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'data/journal_repository.dart';
import 'models/journal_entry.dart';

class JournalDetailPage extends StatefulWidget {
  const JournalDetailPage({super.key, required this.entry});

  final JournalEntry entry;

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  final JournalRepository _repository = const JournalRepository();
  late JournalEntry _entry;
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _titleController = TextEditingController(text: _entry.title ?? '');
    _textController = TextEditingController(text: _entry.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Günlüğünde en azından küçük bir cümle kalsın mı?'),
        ),
      );
      return;
    }

    final updatedEntry = _entry.copyWith(
      title: _titleController.text.trim(),
      text: text,
    );
    await _repository.updateEntry(updatedEntry);

    if (!mounted) {
      return;
    }

    setState(() {
      _entry = updatedEntry;
      _isEditing = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yazın güncellendi.')));
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bu yazıyı silelim mi?'),
          content: const Text('Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _repository.deleteEntry(_entry.id);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop('deleted');
  }

  void _cancelEditing() {
    setState(() {
      _titleController.text = _entry.title ?? '';
      _textController.text = _entry.text;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_displayTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
              ),
              child: _isEditing ? _editingContent() : _readingContent(),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEditing,
                      child: const Text('Vazgeç'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveChanges,
                      child: const Text('Değişiklikleri kaydet'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Düzenle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Sil'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _readingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_displayTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          _formatDate(_entry.createdAt),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${_entry.moodEmoji} ${_entry.moodLabel}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (_entry.promptText != null &&
            _entry.promptText!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Konu: ${_entry.promptText}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
        const SizedBox(height: 18),
        Text(_entry.text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _editingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Başlık'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 300,
          child: TextField(
            controller: _textController,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(hintText: 'Yazını düzenle...'),
          ),
        ),
      ],
    );
  }

  String get _displayTitle {
    final title = _entry.title?.trim();
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
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }
}
