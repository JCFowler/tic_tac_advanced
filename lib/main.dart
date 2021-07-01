import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/l10n.dart';
import 'providers/game_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => LocaleProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GameProvider(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (ctx, locale, _) => MaterialApp(
          localizationsDelegates: [
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          locale: locale.locale,
          title: 'Tic Tac Advanced',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.red),
            ),
            scaffoldBackgroundColor: Colors.blue[50],
          ),
          home: HomeScreen(),
          routes: {
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            GameScreen.routeName: (ctx) => GameScreen(),
          },
        ),
      ),
    );
  }
}
