enum WritingReviewType {
  spelling,
  punctuation,
  capitalization,
  spacing,
  repeatedWord,
  longSentence,
}

class WritingReviewSuggestion {
  const WritingReviewSuggestion({
    required this.type,
    required this.message,
    this.original,
    this.suggestion,
  });

  final WritingReviewType type;
  final String message;
  final String? original;
  final String? suggestion;
}
