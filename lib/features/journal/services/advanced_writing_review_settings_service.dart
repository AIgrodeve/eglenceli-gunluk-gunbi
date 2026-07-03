import 'package:shared_preferences/shared_preferences.dart';

class AdvancedWritingReviewSettingsService {
  const AdvancedWritingReviewSettingsService();

  static const _isEnabledKey = 'advancedWritingReviewEnabled';

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool isEnabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isEnabledKey, isEnabled);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isEnabledKey);
  }
}
