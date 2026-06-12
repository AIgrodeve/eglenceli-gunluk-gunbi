class MoodOption {
  const MoodOption({required this.emoji, required this.label});

  final String emoji;
  final String label;

  String get displayText => '$emoji $label';
}

const moodOptions = [
  MoodOption(emoji: '😊', label: 'Mutlu'),
  MoodOption(emoji: '😢', label: 'Hüzünlü'),
  MoodOption(emoji: '🤩', label: 'Heyecanlı'),
  MoodOption(emoji: '😌', label: 'Sakin'),
  MoodOption(emoji: '😵‍💫', label: 'Karışık'),
  MoodOption(emoji: '⚡', label: 'Enerjik'),
];
