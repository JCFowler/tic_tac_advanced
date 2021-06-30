import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/l10n.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ...L10n.all.map(
            (locale) {
              return ElevatedButton(
                child: Text(locale.languageCode),
                onPressed: () => localeProvider.setLocale(locale),
              );
            },
          ).toList(),
          Text(AppLocalizations.of(context)!.hello('John')),
        ],
      ),
    );
  }
}
