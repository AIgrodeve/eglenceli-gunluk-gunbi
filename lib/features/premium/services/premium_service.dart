import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  const PremiumService();

  static const freeEntryLimit = 15;
  static const _isPremiumUnlockedKey = 'isPremiumUnlocked';

  Future<bool> isPremiumUnlocked() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isPremiumUnlockedKey) ?? false;
  }

  Future<void> setPremiumUnlocked(bool isUnlocked) async {
    // Bu geçici geliştirme/test amaçlı premium durumudur.
    // Gerçek yayın öncesi Google Play Billing ile değiştirilmelidir.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isPremiumUnlockedKey, isUnlocked);
  }

  Future<void> clearPremiumStatus() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isPremiumUnlockedKey);
  }
}
