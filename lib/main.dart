import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/l10n.dart';
import 'providers/game_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/multiplayer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: l10nLanguages,
          locale: locale.locale,
          title: 'Tic Tac Advanced',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryTextTheme: const TextTheme(
              headline6: TextStyle(color: Colors.red),
            ),
            scaffoldBackgroundColor: Colors.blue[50],
          ),
          home: const HomeScreen(),
          routes: {
            SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            GameScreen.routeName: (ctx) => const GameScreen(),
            MultiplayerScreen.routeName: (ctx) => const MultiplayerScreen(),
            'test': (ctx) => const TestScreen(),
          },
        ),
      ),
    );
  }
}
