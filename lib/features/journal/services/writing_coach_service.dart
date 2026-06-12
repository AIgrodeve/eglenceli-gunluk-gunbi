import '../../../core/models/age_group.dart';

class WritingCoachService {
  const WritingCoachService();

  List<String> suggestionsFor({
    required AgeGroup ageGroup,
    required String text,
  }) {
    final wordCount = _countWords(text);
    if (wordCount == 0) {
      return const [
        'Bir kelime bile yeter. Önce küçük bir başlangıç yapalım mı?',
      ];
    }

    if (wordCount <= 7) {
      return _shortTextSuggestions(ageGroup);
    }
    if (wordCount <= 40) {
      return _mediumTextSuggestions(ageGroup);
    }
    return _longTextSuggestions(ageGroup);
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    return trimmed.split(RegExp(r'\s+')).length;
  }

  List<String> _shortTextSuggestions(AgeGroup ageGroup) {
    return switch (ageGroup) {
      AgeGroup.sixToEight => const [
        'Nerede oldu?',
        'Kim vardı?',
        'Bu seni nasıl hissettirdi?',
      ],
      AgeGroup.nineToEleven => const [
        'Bunu nerede yaşadığını da yazabilirsin.',
        'O anda yanında kimler vardı? Onların ne yaptığını da anlatabilirsin.',
        'Bu seni nasıl hissettirdi?',
      ],
    };
  }

  List<String> _mediumTextSuggestions(AgeGroup ageGroup) {
    return switch (ageGroup) {
      AgeGroup.sixToEight => const [
        'Güzel anlattın. Bir duygu daha ekleyebilirsin.',
        'Nasıl başladı?',
        'Sonra ne oldu?',
      ],
      AgeGroup.nineToEleven => const [
        'Güzel anlattın. Şimdi bir duygu ekleyebilirsin.',
        'Olayın nasıl başladığını da yazabilirsin.',
        'Sonunda ne olduğunu anlatmak ister misin?',
      ],
    };
  }

  List<String> _longTextSuggestions(AgeGroup ageGroup) {
    return switch (ageGroup) {
      AgeGroup.sixToEight => const [
        'Harika! Yazın büyüyor.',
        'En sevdiğin cümleyi seçebilirsin.',
        'İstersen küçük bir başlık ekleyebilirsin.',
      ],
      AgeGroup.nineToEleven => const [
        'Harika! Yazın gittikçe güçleniyor.',
        'Bu yazıda en sevdiğin cümleyi seçebilirsin.',
        'Bugünden öğrendiğin şeyi son cümle olarak yazabilirsin.',
      ],
    };
  }
}
