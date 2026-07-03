import 'package:eglenceli_gunluk_gunbi/core/data/app_preferences.dart';
import 'package:eglenceli_gunluk_gunbi/core/data/app_reset_service.dart';
import 'package:eglenceli_gunluk_gunbi/core/models/age_group.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/data/journal_repository.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/models/journal_entry.dart';
import 'package:eglenceli_gunluk_gunbi/features/journal/services/advanced_writing_review_settings_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/parent/services/parent_pin_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/premium/services/premium_service.dart';
import 'package:eglenceli_gunluk_gunbi/features/rewards/services/reward_activity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'clearAllLocalData removes local data and resets parent pin fallback',
    () async {
      SharedPreferences.setMockInitialValues({});

      const preferences = AppPreferences();
      const repository = JournalRepository();
      const premiumService = PremiumService();
      const parentPinService = ParentPinService();
      const rewardActivityService = RewardActivityService();
      const advancedWritingReviewSettingsService =
          AdvancedWritingReviewSettingsService();
      const resetService = AppResetService();

      await preferences.completeOnboarding(
        childName: 'Meryem',
        childGender: 'Kız',
        ageGroup: AgeGroup.nineToTwelve,
      );
      await preferences.updateBookTitle("Meryem'in Günlüğü");
      await repository.addEntry(
        JournalEntry.create(
          childName: 'Meryem',
          moodLabel: 'Mutlu',
          moodEmoji: '😊',
          text: 'Bugün güzel bir gün oldu.',
        ),
      );
      await premiumService.setPremiumUnlocked(true);
      await advancedWritingReviewSettingsService.setEnabled(true);
      await rewardActivityService.markBookOpened();
      await rewardActivityService.markPdfPreviewed();
      await rewardActivityService.incrementCoachHelpCount();
      expect(
        await parentPinService.updatePin(
          currentPin: ParentPinService.defaultPin,
          newPin: '9876',
          repeatedPin: '9876',
        ),
        ParentPinUpdateResult.success,
      );

      await resetService.clearAllLocalData();

      expect(await preferences.hasCompletedOnboarding(), isFalse);
      expect(await preferences.loadChildName(), isNull);
      expect(await preferences.loadChildAgeGroup(), isNull);
      expect(await preferences.loadBookTitle(), isNull);
      expect(await repository.loadEntries(), isEmpty);
      expect(await premiumService.isPremiumUnlocked(), isFalse);
      expect(await advancedWritingReviewSettingsService.isEnabled(), isFalse);
      expect(
        await rewardActivityService.loadStats(),
        isA<dynamic>()
            .having((stats) => stats.hasOpenedBook, 'hasOpenedBook', isFalse)
            .having(
              (stats) => stats.hasPreviewedPdf,
              'hasPreviewedPdf',
              isFalse,
            )
            .having((stats) => stats.coachHelpCount, 'coachHelpCount', 0),
      );
      expect(await parentPinService.verifyPin('9876'), isFalse);
      expect(
        await parentPinService.verifyPin(ParentPinService.defaultPin),
        isTrue,
      );
    },
  );
}
