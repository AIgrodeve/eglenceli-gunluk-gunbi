import '../models/writing_review_suggestion.dart';

class WritingReviewService {
  const WritingReviewService();

  static const int _maxSuggestions = 6;

  static const Map<String, String> _commonCorrections = {
    'herkez': 'herkes',
    'yen\u0131': 'yeni',
    'surum': 's\u00fcr\u00fcm',
    'yayinlandi': 'yay\u0131nland\u0131',
    'yanl\u0131z': 'yaln\u0131z',
    'bir\u015fey': 'bir \u015fey',
    'bisey': 'bir \u015fey',
    'bi\u015fey': 'bir \u015fey',
    'her\u015fey': 'her \u015fey',
    'hicbisey': 'hi\u00e7bir \u015fey',
    'hi\u00e7bi\u015fey': 'hi\u00e7bir \u015fey',
    'hi\u00e7bir\u015fey': 'hi\u00e7bir \u015fey',
    'gelicek': 'gelecek',
    'gidicek': 'gidecek',
    'gidicem': 'gidece\u011fim',
    'gelicem': 'gelece\u011fim',
    'yap\u0131cam': 'yapaca\u011f\u0131m',
    'yapicam': 'yapaca\u011f\u0131m',
    'edecem': 'edece\u011fim',
    'solicem': 's\u00f6yleyece\u011fim',
    's\u00f6licem': 's\u00f6yleyece\u011fim',
    'cokda': '\u00e7ok da',
    '\u00e7okda': '\u00e7ok da',
    'bende': 'ben de',
    'sende': 'sen de',
  };

  List<WritingReviewSuggestion> review(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const [
        WritingReviewSuggestion(
          type: WritingReviewType.punctuation,
          message:
              'G\u00fcnbi yaz\u0131n\u0131 kontrol etmek i\u00e7in \u00f6nce k\u00fc\u00e7\u00fck bir c\u00fcmle bekliyor.',
        ),
      ];
    }

    final suggestions = <WritingReviewSuggestion>[
      ..._spellingSuggestions(trimmed),
      ..._spacingSuggestions(trimmed),
      ..._capitalizationSuggestions(trimmed),
      ..._punctuationSuggestions(trimmed),
      ..._repeatedWordSuggestions(trimmed),
      ..._longSentenceSuggestions(trimmed),
    ];

    return suggestions.take(_maxSuggestions).toList(growable: false);
  }

  List<WritingReviewSuggestion> _spellingSuggestions(String text) {
    final normalizedWords = _words(text).map(_normalizeWord).toSet();
    final suggestions = <WritingReviewSuggestion>[];

    for (final entry in _commonCorrections.entries) {
      if (normalizedWords.contains(entry.key)) {
        suggestions.add(
          WritingReviewSuggestion(
            type: WritingReviewType.spelling,
            original: entry.key,
            suggestion: entry.value,
            message:
                'K\u00fc\u00e7\u00fck bir yaz\u0131m \u00f6nerisi: "${entry.key}" yerine "${entry.value}" yaz\u0131l\u0131r.',
          ),
        );
      }
    }

    return suggestions;
  }

  List<WritingReviewSuggestion> _spacingSuggestions(String text) {
    final suggestions = <WritingReviewSuggestion>[];

    if (text.contains(RegExp(r' {2,}'))) {
      suggestions.add(
        const WritingReviewSuggestion(
          type: WritingReviewType.spacing,
          message:
              'Baz\u0131 yerlerde iki bo\u015fluk yan yana gelmi\u015f. \u0130stersen tek bo\u015fluk b\u0131rakabilirsin.',
        ),
      );
    }

    if (text.contains(RegExp(r'\s+[,.!?;:]'))) {
      suggestions.add(
        const WritingReviewSuggestion(
          type: WritingReviewType.spacing,
          message:
              'Noktalama i\u015faretlerinden \u00f6nce bo\u015fluk b\u0131rakmana gerek yok.',
        ),
      );
    }

    if (text.contains(RegExp(r'[,.!?;:](?=\S)'))) {
      suggestions.add(
        const WritingReviewSuggestion(
          type: WritingReviewType.spacing,
          message:
              'Noktalama i\u015faretinden sonra k\u00fc\u00e7\u00fck bir bo\u015fluk b\u0131rakabilirsin.',
        ),
      );
    }

    return suggestions;
  }

  List<WritingReviewSuggestion> _capitalizationSuggestions(String text) {
    final firstLetter = _firstLetter(text);
    if (firstLetter == null) {
      return const [];
    }

    if (firstLetter != firstLetter.toUpperCase()) {
      return const [
        WritingReviewSuggestion(
          type: WritingReviewType.capitalization,
          message:
              'C\u00fcmlenin ilk harfini b\u00fcy\u00fck yazarsan yaz\u0131n daha d\u00fczenli g\u00f6r\u00fcn\u00fcr.',
        ),
      ];
    }

    return const [];
  }

  List<WritingReviewSuggestion> _punctuationSuggestions(String text) {
    if (!RegExp(r'[.!?]$').hasMatch(text)) {
      return const [
        WritingReviewSuggestion(
          type: WritingReviewType.punctuation,
          message:
              'C\u00fcmlenin sonuna nokta, soru i\u015fareti veya \u00fcnlem ekleyebilirsin.',
        ),
      ];
    }
    return const [];
  }

  List<WritingReviewSuggestion> _repeatedWordSuggestions(String text) {
    final words = _words(text).map(_normalizeWord).where((word) {
      return word.isNotEmpty;
    }).toList();

    for (var index = 1; index < words.length; index++) {
      if (words[index] == words[index - 1]) {
        return [
          WritingReviewSuggestion(
            type: WritingReviewType.repeatedWord,
            original: words[index],
            message:
                '"${words[index]}" kelimesi yan yana tekrar etmi\u015f. \u0130stersen birini silebilirsin.',
          ),
        ];
      }
    }

    return const [];
  }

  List<WritingReviewSuggestion> _longSentenceSuggestions(String text) {
    final sentences = text
        .split(RegExp(r'[.!?]+'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.isNotEmpty);

    for (final sentence in sentences) {
      if (_words(sentence).length > 28) {
        return const [
          WritingReviewSuggestion(
            type: WritingReviewType.longSentence,
            message:
                'Bu c\u00fcmle biraz uzam\u0131\u015f. \u0130stersen iki k\u0131sa c\u00fcmleye b\u00f6lebilirsin.',
          ),
        ];
      }
    }

    return const [];
  }

  String? _firstLetter(String text) {
    for (final rune in text.runes) {
      if (_isLetterRune(rune)) {
        return String.fromCharCode(rune);
      }
    }
    return null;
  }

  List<String> _words(String text) {
    final words = <String>[];
    final buffer = StringBuffer();

    for (final rune in text.runes) {
      if (_isWordRune(rune)) {
        buffer.writeCharCode(rune);
      } else if (buffer.isNotEmpty) {
        words.add(buffer.toString());
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      words.add(buffer.toString());
    }

    return words;
  }

  bool _isWordRune(int rune) {
    return _isLetterRune(rune) || (rune >= 48 && rune <= 57);
  }

  bool _isLetterRune(int rune) {
    return (rune >= 65 && rune <= 90) ||
        (rune >= 97 && rune <= 122) ||
        rune == 0x00c7 ||
        rune == 0x00e7 ||
        rune == 0x011e ||
        rune == 0x011f ||
        rune == 0x0130 ||
        rune == 0x0131 ||
        rune == 0x00d6 ||
        rune == 0x00f6 ||
        rune == 0x015e ||
        rune == 0x015f ||
        rune == 0x00dc ||
        rune == 0x00fc;
  }

  String _normalizeWord(String word) {
    return word.toLowerCase().replaceAll('\u0130', 'i').trim();
  }
}
