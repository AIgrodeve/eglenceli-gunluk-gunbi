import 'dart:math';

import '../../../core/models/age_group.dart';

class WritingPromptService {
  WritingPromptService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _youngPrompts = [
    'Bugün seni en çok ne güldürdü?',
    'Bugün okulda ya da evde ne yaptın?',
    'Bugün hangi oyunu oynadın?',
    'Bugün en sevdiğin şey neydi?',
    'Bugün kendini nasıl hissettin? Bir cümleyle anlat.',
    'Bugün bir arkadaşınla ne yaptın?',
    'Bugün öğrendiğin yeni bir şeyi yaz.',
  ];

  static const _olderPrompts = [
    'Bugün yaşadığın bir olayı başı, ortası ve sonuyla anlat.',
    'Bugün seni düşündüren bir şey oldu mu?',
    'Bugün birine söylemek isteyip söyleyemediğin bir şey var mı?',
    'Bugün öğrendiğin bir şeyi kendi cümlelerinle anlat.',
    'Bugün yaşadığın en güzel anı detaylarıyla yaz.',
    'Bugün zorlandığın bir şey oldu mu? Nasıl hissettin?',
    'Bugünü bir hikâye gibi anlatsan nasıl başlardı?',
  ];

  String randomPromptFor(AgeGroup ageGroup, {String? except}) {
    final prompts = promptsFor(ageGroup);
    final availablePrompts = prompts
        .where((prompt) => prompt != except)
        .toList();
    final source = availablePrompts.isEmpty ? prompts : availablePrompts;
    return source[_random.nextInt(source.length)];
  }

  List<String> promptsFor(AgeGroup ageGroup) {
    return switch (ageGroup) {
      AgeGroup.sixToEight => _youngPrompts,
      AgeGroup.nineToEleven => _olderPrompts,
    };
  }
}
