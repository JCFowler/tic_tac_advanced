import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<bool> saveLocale(Locale locale) async {
    final _prefs = await SharedPreferences.getInstance();
    final localeJson = json.encode({
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode
    });
    return _prefs.setString('locale', localeJson);
  }

  static Future<Locale?> getLocale() async {
    final _prefs = await SharedPreferences.getInstance();
    final localeJson = _prefs.getString('locale');

    if (localeJson == null) return null;

    final data = json.decode(localeJson);

    return Locale(data['languageCode'], data['countryCode']);
  }
}
