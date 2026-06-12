import 'package:flutter/material.dart';

import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import 'journal_page.dart';
import 'mood_options.dart';

class MoodSelectionPage extends StatefulWidget {
  const MoodSelectionPage({
    super.key,
    required this.childName,
    required this.ageGroup,
  });

  final String childName;
  final AgeGroup ageGroup;

  @override
  State<MoodSelectionPage> createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  MoodOption? _selectedMood;

  void _continueToJournal() {
    final mood = _selectedMood;
    if (mood == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JournalPage(
          childName: widget.childName,
          ageGroup: widget.ageGroup,
          moodLabel: mood.label,
          moodEmoji: mood.emoji,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugün yaz')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: MascotWidget(
                  size: 88,
                  mood: MascotMood.supportive,
                  showShadow: false,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bugün nasıl hissediyorsun?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Günlüğüne başlamadan önce bir duygu seç.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final mood in moodOptions)
                        ChoiceChip(
                          label: Text(mood.displayText),
                          selected: _selectedMood == mood,
                          onSelected: (_) {
                            setState(() => _selectedMood = mood);
                          },
                          selectedColor: AppTheme.softBlue,
                          backgroundColor: Colors.white,
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
                          side: BorderSide(
                            color: _selectedMood == mood
                                ? AppTheme.softBlue
                                : AppTheme.pastelYellow,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selectedMood == null ? null : _continueToJournal,
                child: const Text('Yazmaya başla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
