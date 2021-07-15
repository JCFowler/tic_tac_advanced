import 'package:flutter/material.dart';

import '../providers/game_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';

class SinglePlayerScreen extends StatelessWidget {
  static const routeName = '/single-player-select';
  const SinglePlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: const [
              AppTitle('singlePlayer'),
              NavigatorAppButton(
                'random',
                routeName: GameScreen.routeName,
                gameType: GameType.Random,
              ),
              NavigatorAppButton(
                'easy',
                routeName: GameScreen.routeName,
                gameType: GameType.Easy,
              ),
              NavigatorAppButton(
                'normal',
                routeName: GameScreen.routeName,
                gameType: GameType.Normal,
              ),
              NavigatorAppButton(
                'hard',
                routeName: GameScreen.routeName,
                gameType: GameType.Hard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
