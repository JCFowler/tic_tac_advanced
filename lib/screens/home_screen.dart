import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'multiplayer_screen.dart';
import 'single_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AppTitle('Tic Tac\nAdvanced'),
            Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      NavigatorAppButton(
                        'singlePlayer',
                        routeName: SinglePlayerScreen.routeName,
                      ),
                      NavigatorAppButton(
                        'multiplayer',
                        routeName: MultiplayerScreen.routeName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
