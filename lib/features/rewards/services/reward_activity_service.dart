import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_activity_stats.dart';

class RewardActivityService {
  const RewardActivityService();

  static const _bookOpenedKey = 'rewardBookOpened';
  static const _pdfPreviewedKey = 'rewardPdfPreviewed';
  static const _coachHelpCountKey = 'rewardCoachHelpCount';

  Future<RewardActivityStats> loadStats() async {
    final preferences = await SharedPreferences.getInstance();
    return RewardActivityStats(
      hasOpenedBook: preferences.getBool(_bookOpenedKey) ?? false,
      hasPreviewedPdf: preferences.getBool(_pdfPreviewedKey) ?? false,
      coachHelpCount: preferences.getInt(_coachHelpCountKey) ?? 0,
    );
  }

  Future<void> markBookOpened() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_bookOpenedKey, true);
  }

  Future<void> markPdfPreviewed() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_pdfPreviewedKey, true);
  }

  Future<void> incrementCoachHelpCount() async {
    final preferences = await SharedPreferences.getInstance();
    final currentCount = preferences.getInt(_coachHelpCountKey) ?? 0;
    await preferences.setInt(_coachHelpCountKey, currentCount + 1);
  }

  Future<void> clearProgress() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_bookOpenedKey);
    await preferences.remove(_pdfPreviewedKey);
    await preferences.remove(_coachHelpCountKey);
  }
}
