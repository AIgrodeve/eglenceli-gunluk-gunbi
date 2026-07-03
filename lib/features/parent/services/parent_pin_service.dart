import 'package:shared_preferences/shared_preferences.dart';

class ParentPinService {
  const ParentPinService();

  static const defaultPin = '1234';
  static const _parentPinKey = 'parentPin';

  Future<bool> verifyPin(String pin) async {
    final savedPin = await loadPin();
    return pin.trim() == savedPin;
  }

  Future<String> loadPin() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPin = preferences.getString(_parentPinKey)?.trim();
    if (savedPin == null || savedPin.isEmpty) {
      return defaultPin;
    }
    return savedPin;
  }

  Future<ParentPinUpdateResult> updatePin({
    required String currentPin,
    required String newPin,
    required String repeatedPin,
  }) async {
    final normalizedCurrentPin = currentPin.trim();
    final normalizedNewPin = newPin.trim();
    final normalizedRepeatedPin = repeatedPin.trim();

    if (normalizedCurrentPin.isEmpty ||
        normalizedNewPin.isEmpty ||
        normalizedRepeatedPin.isEmpty) {
      return ParentPinUpdateResult.empty;
    }
    if (normalizedNewPin.length < 4) {
      return ParentPinUpdateResult.tooShort;
    }
    if (normalizedNewPin != normalizedRepeatedPin) {
      return ParentPinUpdateResult.mismatch;
    }
    if (!await verifyPin(normalizedCurrentPin)) {
      return ParentPinUpdateResult.wrongCurrentPin;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_parentPinKey, normalizedNewPin);
    return ParentPinUpdateResult.success;
  }

  Future<void> clearPin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_parentPinKey);
  }
}

enum ParentPinUpdateResult {
  success,
  empty,
  tooShort,
  mismatch,
  wrongCurrentPin,
}
