import 'package:eglenceli_gunluk_gunbi/core/models/age_group.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/services/advanced_writing_review_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/services/writing_coach_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/services/writing_prompt_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/services/writing_review_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WritingPromptService', () {
    test('adds mood-aware prompts before age prompts', () {
      final service = WritingPromptService();

      final prompts = service.promptsFor(
        AgeGroup.nineToTwelve,
        moodLabel: 'Hüzünlü',
      );

      expect(prompts.first, contains('seni üzen olayı'));
      expect(
        prompts,
        contains('Bugün yaşadığın bir olayı başı, ortası ve sonuyla anlat.'),
      );
    });
  });

  group('WritingCoachService', () {
    test('returns a supportive mood-aware message for empty text', () {
      const service = WritingCoachService();

      final suggestions = service.suggestionsFor(
        ageGroup: AgeGroup.sixToEight,
        moodLabel: 'Karışık',
        text: '',
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single, contains('Karışık hisler olabilir'));
    });

    test('keeps short text help concise and adds mood context', () {
      const service = WritingCoachService();

      final suggestions = service.suggestionsFor(
        ageGroup: AgeGroup.nineToTwelve,
        moodLabel: 'Enerjik',
        text: 'Parkta koştum',
      );

      expect(suggestions, hasLength(3));
      expect(suggestions.first, contains('Enerjik hissettiğin anı'));
    });
  });

  group('WritingReviewService', () {
    test('finds common spelling and punctuation suggestions', () {
      const service = WritingReviewService();

      final suggestions = service.review('bugÃ¼n herkez geldi');

      expect(
        suggestions.any(
          (suggestion) =>
              suggestion.original == 'herkez' &&
              suggestion.suggestion == 'herkes',
        ),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) => suggestion.message.contains('ilk harfini'),
        ),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) => suggestion.message.contains('sonuna nokta'),
        ),
        isTrue,
      );
    });

    test('finds repeated words and spacing suggestions', () {
      const service = WritingReviewService();

      final suggestions = service.review('BugÃ¼n  oyun oyun oynadÄ±m .');

      expect(
        suggestions.any(
          (suggestion) => suggestion.message.contains('iki bo\u015fluk'),
        ),
        isTrue,
      );
      expect(
        suggestions.any((suggestion) => suggestion.original == 'oyun'),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) => suggestion.message.contains('\u00f6nce bo\u015fluk'),
        ),
        isTrue,
      );
    });

    test('finds missing Turkish character suggestions in a sentence', () {
      const service = WritingReviewService();

      final suggestions = service.review(
        'Bu uygulamada yen\u0131 surum yayinlandi',
      );

      expect(
        suggestions.any(
          (suggestion) =>
              suggestion.original == 'yen\u0131' &&
              suggestion.suggestion == 'yeni',
        ),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) =>
              suggestion.original == 'surum' &&
              suggestion.suggestion == 's\u00fcr\u00fcm',
        ),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) =>
              suggestion.original == 'yayinlandi' &&
              suggestion.suggestion == 'yay\u0131nland\u0131',
        ),
        isTrue,
      );
      expect(
        suggestions.any(
          (suggestion) => suggestion.message.contains('sonuna nokta'),
        ),
        isTrue,
      );
    });
  });

  group('AdvancedWritingReviewService', () {
    test(
      'does not use local fallback when backend is not configured',
      () async {
        const service = AdvancedWritingReviewService(endpointUrl: '');

        final result = await service.review(
          text: 'Bu uygulamada yen\u0131 surum yayinlandi',
          ageGroup: AgeGroup.nineToTwelve,
          moodLabel: 'Sakin',
        );

        expect(result.status, AdvancedWritingReviewStatus.notConfigured);
        expect(result.suggestions, isEmpty);
        expect(result.message, contains('hen\u00fcz ba\u011flanmad\u0131'));
      },
    );
  });
}
