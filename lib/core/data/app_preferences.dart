import 'package:shared_preferences/shared_preferences.dart';

import '../models/age_group.dart';

class AppPreferences {
  const AppPreferences();

  static const _childNameKey = 'child_name';
  static const _childAgeGroupKey = 'childAgeGroup';
  static const _onboardingCompletedKey = 'onboarding_completed';

  Future<String?> loadChildName() async {
    final preferences = await SharedPreferences.getInstance();
    final childName = preferences.getString(_childNameKey)?.trim();
    if (childName == null || childName.isEmpty) {
      return null;
    }
    return childName;
  }

  Future<AgeGroup?> loadChildAgeGroup() async {
    final preferences = await SharedPreferences.getInstance();
    return AgeGroup.fromStorageValue(preferences.getString(_childAgeGroupKey));
  }

  Future<bool> hasCompletedOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding({
    required String childName,
    required AgeGroup ageGroup,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_childNameKey, childName.trim());
    await preferences.setString(_childAgeGroupKey, ageGroup.storageValue);
    await preferences.setBool(_onboardingCompletedKey, true);
  }
}
