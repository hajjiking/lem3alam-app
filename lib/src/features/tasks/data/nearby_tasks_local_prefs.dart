import 'package:shared_preferences/shared_preferences.dart';

class NearbyTasksLocalPrefs {
  static const _consentKey = 'nearby_tasks_location_consent';
  static const _radiusKey = 'nearby_tasks_radius_km';

  Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  Future<void> setConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);
  }

  Future<int?> radiusKm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_radiusKey);
  }

  Future<void> setRadiusKm(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_radiusKey, value);
  }
}

