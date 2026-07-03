import '../../features/journal/data/journal_repository.dart';
import '../../features/journal/services/advanced_writing_review_settings_service.dart';
import '../../features/parent/services/parent_pin_service.dart';
import '../../features/premium/services/premium_service.dart';
import '../../features/rewards/services/reward_activity_service.dart';
import 'app_preferences.dart';

class AppResetService {
  const AppResetService({
    this.preferences = const AppPreferences(),
    this.journalRepository = const JournalRepository(),
    this.premiumService = const PremiumService(),
    this.parentPinService = const ParentPinService(),
    this.rewardActivityService = const RewardActivityService(),
    this.advancedWritingReviewSettingsService =
        const AdvancedWritingReviewSettingsService(),
  });

  final AppPreferences preferences;
  final JournalRepository journalRepository;
  final PremiumService premiumService;
  final ParentPinService parentPinService;
  final RewardActivityService rewardActivityService;
  final AdvancedWritingReviewSettingsService
  advancedWritingReviewSettingsService;

  Future<void> clearAllLocalData() async {
    await journalRepository.clearAllEntries();
    await preferences.clearLocalPreferences();
    await premiumService.clearPremiumStatus();
    await parentPinService.clearPin();
    await rewardActivityService.clearProgress();
    await advancedWritingReviewSettingsService.clear();
  }
}
