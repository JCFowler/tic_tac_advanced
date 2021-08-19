import 'package:flutter/material.dart';
import 'package:tic_tac_advanced/services/local_storage_service.dart';

import '../models/l10n.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  LocaleProvider(Locale? initalLocale) {
    _locale = initalLocale;
  }

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!l10nLanguages.contains(locale)) return;

    LocalStorageService.saveLocale(locale);

    _locale = locale;
    notifyListeners();
  }
}
