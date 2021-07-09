import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../widgets/background_gradient.dart';

import '../models/l10n.dart';
import '../providers/locale_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_title.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const AppTitle('settings'),
              ...l10nLanguages.map(
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
        ),
      ),
    );
  }
}
