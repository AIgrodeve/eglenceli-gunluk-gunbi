import '../../../core/models/age_group.dart';

class WritingCoachService {
  const WritingCoachService();

  List<String> suggestionsFor({
    required AgeGroup ageGroup,
    required String text,
    String? moodLabel,
  }) {
    final wordCount = _countWords(text);
    if (wordCount == 0) {
      return [_emptyTextSuggestion(ageGroup, moodLabel)];
    }

    if (wordCount <= 7) {
      return _withMoodSuggestion(
        _shortTextSuggestions(ageGroup),
        ageGroup,
        moodLabel,
      );
    }
    if (wordCount <= 40) {
      return _withMoodSuggestion(
        _mediumTextSuggestions(ageGroup),
        ageGroup,
        moodLabel,
      );
    }
    return _withMoodSuggestion(
      _longTextSuggestions(ageGroup),
      ageGroup,
      moodLabel,
    );
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
      AgeGroup.nineToTwelve => const [
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
      AgeGroup.nineToTwelve => const [
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
      AgeGroup.nineToTwelve => const [
        'Harika! Yazın gittikçe güçleniyor.',
        'Bu yazıda en sevdiğin cümleyi seçebilirsin.',
        'Bugünden öğrendiğin şeyi son cümle olarak yazabilirsin.',
      ],
    };
  }

  String _emptyTextSuggestion(AgeGroup ageGroup, String? moodLabel) {
    final moodSuggestion = _moodSuggestion(ageGroup, moodLabel);
    if (moodSuggestion != null) {
      return moodSuggestion;
    }
    return 'Bir kelime bile yeter. Önce küçük bir başlangıç yapalım mı?';
  }

  List<String> _withMoodSuggestion(
    List<String> suggestions,
    AgeGroup ageGroup,
    String? moodLabel,
  ) {
    final moodSuggestion = _moodSuggestion(ageGroup, moodLabel);
    if (moodSuggestion == null) {
      return suggestions;
    }

    return [moodSuggestion, ...suggestions.take(2)];
  }

  String? _moodSuggestion(AgeGroup ageGroup, String? moodLabel) {
    final normalizedMood = moodLabel?.toLowerCase().trim();
    if (normalizedMood == null || normalizedMood.isEmpty) {
      return null;
    }

    return switch ((ageGroup, normalizedMood)) {
      (AgeGroup.sixToEight, 'mutlu') =>
        'Mutlu anını küçük bir resim gibi anlatabilirsin.',
      (AgeGroup.nineToTwelve, 'mutlu') =>
        'Mutlu olduğun anın neden özel geldiğini de yazabilirsin.',
      (AgeGroup.sixToEight, 'hüzünlü') =>
        'Üzgün hissettiysen bunu yavaşça yazabilirsin. Günbi yanında.',
      (AgeGroup.nineToTwelve, 'hüzünlü') =>
        'Hüzünlü hissettiğin anı ve sana neyin iyi gelebileceğini yazabilirsin.',
      (AgeGroup.sixToEight, 'heyecanlı') =>
        'Heyecanın nerede başladı? Bir cümleyle anlatabilirsin.',
      (AgeGroup.nineToTwelve, 'heyecanlı') =>
        'Heyecanlandığın anı anlatırken önce ne olduğunu, sonra nasıl hissettiğini ekleyebilirsin.',
      (AgeGroup.sixToEight, 'sakin') =>
        'Sakin anını anlatırken etrafında neler vardı?',
      (AgeGroup.nineToTwelve, 'sakin') =>
        'Sakin hissettiğin anın sana ne düşündürdüğünü de yazabilirsin.',
      (AgeGroup.sixToEight, 'karışık') =>
        'Karışık hisler olabilir. Birini seçip oradan başlayabilirsin.',
      (AgeGroup.nineToTwelve, 'karışık') =>
        'Karışık duygularını sırayla yazmak zihnini toparlamana yardım edebilir.',
      (AgeGroup.sixToEight, 'enerjik') =>
        'Enerjini nerede kullandın? Oyunu ya da hareketi anlat.',
      (AgeGroup.nineToTwelve, 'enerjik') =>
        'Enerjik hissettiğin anı, nerede olduğunu ve kimin yanında olduğunu ekleyerek anlatabilirsin.',
      _ => null,
    };
  }
}
