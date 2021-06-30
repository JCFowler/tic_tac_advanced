import 'package:flutter/material.dart';

import '../models/l10n.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  // LocaleProvider(this._locale);

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }
}
