import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  const AppPreferences();

  static const _childNameKey = 'child_name';
  static const _onboardingCompletedKey = 'onboarding_completed';

  Future<String?> loadChildName() async {
    final preferences = await SharedPreferences.getInstance();
    final childName = preferences.getString(_childNameKey)?.trim();
    if (childName == null || childName.isEmpty) {
      return null;
    }
    return childName;
  }

  Future<bool> hasCompletedOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding({required String childName}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_childNameKey, childName.trim());
    await preferences.setBool(_onboardingCompletedKey, true);
  }
}
