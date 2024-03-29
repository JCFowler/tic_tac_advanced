import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'helpers/connection_status.dart';
import 'models/l10n.dart';
import 'providers/ad_provider.dart';
import 'providers/game_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/user_provider.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/multiplayer_screen.dart';
import 'screens/online_screen.dart';
import 'screens/single_player_screen.dart';
import 'services/local_storage_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Locale? initalLocale;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initalLocale = await LocalStorageService.getLocale();
  ConnectionStatus connectionStatus = ConnectionStatus.getInstance();
  connectionStatus.initialize();

  final adState = AdProvider(MobileAds.instance.initialize());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    await Firebase.initializeApp();
    runApp(
      Provider.value(
        value: adState,
        builder: (ctx, _) => const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  _fadeTransition(Widget widget) {
    return PageTransition(
      child: widget,
      type: PageTransitionType.fade,
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => LocaleProvider(initalLocale),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<UserProvider, GameProvider>(
          create: (ctx) => GameProvider('', ''),
          update: (ctx, user, game) {
            game!.uid = user.uid;
            game.username = user.username;
            game.user = user.user;
            return game;
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (ctx, localeProvider, _) => MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          locale: localeProvider.locale,
          supportedLocales: l10nLanguages,
          title: 'Tic Tac Advanced',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            secondaryHeaderColor: Colors.purple,
            dialogBackgroundColor: Colors.blue.shade50.withOpacity(0.5),
            scaffoldBackgroundColor: Colors.blue.shade50,
            primaryTextTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.blue),
            ),
            fontFamily: 'Acme',
          ),
          home: const HomeScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case GameScreen.routeName:
                return PageTransition(
                  child: const GameScreen(),
                  type: PageTransitionType.size,
                  alignment: Alignment.center,
                );
              case SinglePlayerScreen.routeName:
                return _fadeTransition(const SinglePlayerScreen());
              case MultiplayerScreen.routeName:
                return _fadeTransition(const MultiplayerScreen());
              case OnlineScreen.routeName:
                return _fadeTransition(const OnlineScreen());
              default:
                return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
          },
          builder: (context, child) {
            return Scaffold(
              body: child,
            );
          },
        ),
      ),
    );
  }
}
