import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'multiplayer_screen.dart';
import 'single_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Column(
          children: [
            SizedBox(height: _deviceSize.height * 0.1),
            Container(
              height: _deviceSize.height * 0.40,
              width: _deviceSize.width * 0.95,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/tic-tac-advanced.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
      ),
    );
  }
}
