import 'package:flutter/material.dart';

import '../models/l10n.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!l10nLanguages.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }
}
