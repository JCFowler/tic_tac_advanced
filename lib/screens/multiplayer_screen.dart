import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/translate_helper.dart';
import '../models/constants.dart';
import '../providers/user_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';
import 'online_screen.dart';

class MultiplayerScreen extends StatelessWidget {
  static const routeName = '/multiplayer-select';

  const MultiplayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppTitle(translate('multiplayer')),
            Consumer<UserProvider>(
              builder: (ctx, userProvider, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NavigatorAppButton(
                    'localPlay',
                    routeName: GameScreen.routeName,
                    gameType: GameType.Local,
                  ),
                  userProvider.uid == ''
                      ? const LoadingAppButton()
                      : const NavigatorAppButton(
                          'onlinePlay',
                          routeName: OnlineScreen.routeName,
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
