import 'dart:math';

import '../../../core/models/age_group.dart';

class WritingPromptService {
  WritingPromptService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _youngPrompts = [
    'Bugün seni en çok ne mutlu etti?',
    'Bugün okulda ya da evde ne yaptın?',
    'Bugün hangi oyunu oynadın?',
    'Bugün kiminle güzel vakit geçirdin?',
    'Bugün en sevdiğin şey neydi?',
    'Bugün kendini nasıl hissettin? Bir cümleyle anlat.',
    'Bugün öğrendiğin yeni bir şeyi yaz.',
  ];

  static const _olderPrompts = [
    'Bugün yaşadığın bir olayı başı, ortası ve sonuyla anlat.',
    'Bugün seni düşündüren bir şey oldu mu?',
    'Bugün kendinle ilgili ne fark ettin?',
    'Bugün birine söylemek isteyip söyleyemediğin bir şey var mı?',
    'Bugün öğrendiğin bir şeyi kendi cümlelerinle anlat.',
    'Bugün yaşadığın en güzel anı detaylarıyla yaz.',
    'Bugün zorlandığın bir şey oldu mu? Nasıl hissettin?',
    'Bugünü bir hikâye gibi anlatsan nasıl başlardı?',
  ];

  String randomPromptFor(
    AgeGroup ageGroup, {
    String? moodLabel,
    String? except,
  }) {
    final prompts = promptsFor(ageGroup, moodLabel: moodLabel);
    final availablePrompts = prompts
        .where((prompt) => prompt != except)
        .toList();
    final source = availablePrompts.isEmpty ? prompts : availablePrompts;
    return source[_random.nextInt(source.length)];
  }

  List<String> promptsFor(AgeGroup ageGroup, {String? moodLabel}) {
    final moodPrompts = _moodPromptsFor(ageGroup, moodLabel);
    final agePrompts = switch (ageGroup) {
      AgeGroup.sixToEight => _youngPrompts,
      AgeGroup.nineToTwelve => _olderPrompts,
    };
    return [...moodPrompts, ...agePrompts];
  }

  List<String> _moodPromptsFor(AgeGroup ageGroup, String? moodLabel) {
    final normalizedMood = moodLabel?.toLowerCase().trim();
    if (normalizedMood == null || normalizedMood.isEmpty) {
      return const [];
    }

    return switch ((ageGroup, normalizedMood)) {
      (AgeGroup.sixToEight, 'mutlu') => const [
        'Bugün seni mutlu eden şeyi anlatır mısın?',
        'Bugün gülümsediğin bir an var mıydı?',
      ],
      (AgeGroup.nineToTwelve, 'mutlu') => const [
        'Bugün seni mutlu eden anı biraz detaylandırabilir misin?',
        'Bu mutluluğu başka biriyle paylaşmak istesen ne söylerdin?',
      ],
      (AgeGroup.sixToEight, 'hüzünlü') => const [
        'Bugün seni üzen şeyi istersen yavaşça anlatabilirsin.',
        'Üzgünken yanında kim olsun isterdin?',
      ],
      (AgeGroup.nineToTwelve, 'hüzünlü') => const [
        'Bugün seni üzen olayı ve sonrasında neye ihtiyaç duyduğunu yazabilirsin.',
        'Bu duyguyu biraz hafifletmek için ne iyi gelebilirdi?',
      ],
      (AgeGroup.sixToEight, 'heyecanlı') => const [
        'Bugün seni en çok heyecanlandıran şey neydi?',
        'Heyecanın nerede başladı?',
      ],
      (AgeGroup.nineToTwelve, 'heyecanlı') => const [
        'Bugün heyecanlandığın anı başı, ortası ve sonuyla anlat.',
        'Heyecanlanınca aklından neler geçti?',
      ],
      (AgeGroup.sixToEight, 'sakin') => const [
        'Bugün sakin hissettiğin güzel bir anı yaz.',
        'Sana bugün huzur veren şey neydi?',
      ],
      (AgeGroup.nineToTwelve, 'sakin') => const [
        'Bugün seni sakinleştiren anı ve o anda neler fark ettiğini yaz.',
        'Sakin hissettiğin yerde neler vardı?',
      ],
      (AgeGroup.sixToEight, 'karışık') => const [
        'Bugün kafanı karıştıran şeyi küçük küçük anlatabilirsin.',
        'Birden fazla duygu yaşadıysan hangileri vardı?',
      ],
      (AgeGroup.nineToTwelve, 'karışık') => const [
        'Bugün aynı anda birkaç duygu hissettiysen onları sırayla anlatabilirsin.',
        'Karışık hissetmene neden olan olay neydi?',
      ],
      (AgeGroup.sixToEight, 'enerjik') => const [
        'Bugün en hareketli anın neydi?',
        'Enerjini hangi oyunda ya da işte kullandın?',
      ],
      (AgeGroup.nineToTwelve, 'enerjik') => const [
        'Bugün enerjini en çok nerede kullandığını ve bunun sana nasıl hissettirdiğini yaz.',
        'Bugünkü hareketli anını bir hikaye gibi anlat.',
      ],
      _ => const [],
    };
  }
}
