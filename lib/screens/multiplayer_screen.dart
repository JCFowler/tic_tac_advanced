import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';

class MultiplayerScreen extends StatelessWidget {
  static const routeName = '/multiplayer-select';
  const MultiplayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: const [
              AppTitle('multiplayer'),
              NavigatorAppButton(
                'localPlay',
                routeName: GameScreen.routeName,
              ),
              NavigatorAppButton(
                'onlinePlay',
                routeName: GameScreen.routeName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
