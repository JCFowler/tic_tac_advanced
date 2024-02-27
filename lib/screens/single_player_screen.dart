import 'package:flutter/material.dart';

import '../helpers/translate_helper.dart';
import '../models/constants.dart';
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
            children: [
              AppTitle(translate('singlePlayer')),
              const NavigatorAppButton(
                'easy',
                routeName: GameScreen.routeName,
                gameType: GameType.Easy,
              ),
              const NavigatorAppButton(
                'normal',
                routeName: GameScreen.routeName,
                gameType: GameType.Normal,
              ),
              const NavigatorAppButton(
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
