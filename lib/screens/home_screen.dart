import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_advanced/providers/game_provider.dart';
import 'package:tic_tac_advanced/widgets/app_title.dart';

import '../widgets/app_button.dart';
import 'game_screen.dart';
import 'multiplayer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: Column(
              children: [
                const AppTitle('Tic Tac\nAdvanced'),
                Expanded(
                  child: Column(
                    children: [
                      AppButton(
                        'Single Player',
                        () {
                          Provider.of<GameProvider>(context, listen: false)
                              .setIsAIGame(true);
                          Navigator.of(context).pushNamed(
                            GameScreen.routeName,
                          );
                        },
                      ),
                      AppButton(
                        'Multiplayer',
                        () {
                          Provider.of<GameProvider>(context, listen: false)
                              .setIsAIGame(false);
                          Navigator.of(context).pushNamed(
                            MultiplayerScreen.routeName,
                          );
                        },
                      ),
                      AppButton(
                        'Settings',
                        () => Navigator.of(context).pushNamed(
                          SettingsScreen.routeName,
                        ),
                      ),
                      AppButton(
                        'Test',
                        () => Navigator.of(context).pushNamed(
                          'test',
                        ),
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
