import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.5),
                  Colors.red.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SizedBox(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 50.0),
                    // transform: Matrix4.rotationZ(-15 * pi / 180)
                    //   ..translate(10.0),
                    child: const Text(
                      'Tic Tac\nAdvanced',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(GameScreen.routeName),
                        child: const Text('Play'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(SettingsScreen.routeName),
                        child: const Text('Settings'),
                      ),
                      Text(AppLocalizations.of(context)!.helloWorld)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
