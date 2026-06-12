class JournalEntry {
  const JournalEntry({
    required this.childName,
    required this.moodLabel,
    required this.moodEmoji,
    required this.text,
    required this.createdAt,
    this.title,
    this.promptText,
  });

  final String childName;
  final String moodLabel;
  final String moodEmoji;
  final String text;
  final DateTime createdAt;
  final String? title;
  final String? promptText;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      childName: json['childName'] as String? ?? '',
      moodLabel: json['moodLabel'] as String? ?? '',
      moodEmoji: json['moodEmoji'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      title: json['title'] as String?,
      promptText: json['promptText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childName': childName,
      'moodLabel': moodLabel,
      'moodEmoji': moodEmoji,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (title != null && title!.trim().isNotEmpty) 'title': title,
      if (promptText != null && promptText!.trim().isNotEmpty)
        'promptText': promptText,
    };
  }

  static JournalEntry create({
    required String childName,
    required String moodLabel,
    required String moodEmoji,
    required String text,
    String? title,
    String? promptText,
  }) {
    return JournalEntry(
      childName: childName,
      moodLabel: moodLabel,
      moodEmoji: moodEmoji,
      text: text,
      createdAt: DateTime.now(),
      title: title,
      promptText: promptText,
    );
  }
}
