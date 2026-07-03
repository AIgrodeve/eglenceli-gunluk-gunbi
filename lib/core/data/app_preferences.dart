import 'package:shared_preferences/shared_preferences.dart';

import '../models/age_group.dart';

class AppPreferences {
  const AppPreferences();

  static const _childNameKey = 'child_name';
  static const _childAgeGroupKey = 'childAgeGroup';
  static const _childGenderKey = 'childGender';
  static const _bookTitleKey = 'bookTitle';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _parentPinKey = 'parentPin';

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
    required String childGender,
    required AgeGroup ageGroup,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_childNameKey, childName.trim());
    await preferences.setString(_childGenderKey, childGender.trim());
    await preferences.setString(_childAgeGroupKey, ageGroup.storageValue);
    await preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<void> updateChildName(String childName) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_childNameKey, childName.trim());
  }

  Future<void> updateChildAgeGroup(AgeGroup ageGroup) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_childAgeGroupKey, ageGroup.storageValue);
  }

  Future<String?> loadBookTitle() async {
    final preferences = await SharedPreferences.getInstance();
    final bookTitle = preferences.getString(_bookTitleKey)?.trim();
    if (bookTitle == null || bookTitle.isEmpty) {
      return null;
    }
    return bookTitle;
  }

  Future<void> updateBookTitle(String bookTitle) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_bookTitleKey, bookTitle.trim());
  }

  Future<void> clearLocalPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_childNameKey);
    await preferences.remove(_childAgeGroupKey);
    await preferences.remove(_childGenderKey);
    await preferences.remove(_bookTitleKey);
    await preferences.remove(_onboardingCompletedKey);
    await preferences.remove(_parentPinKey);
  }
}
