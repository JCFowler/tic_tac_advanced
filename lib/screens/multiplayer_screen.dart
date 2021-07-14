import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.uid == '') {
      userProvider.createAnonymousUser();
    }

    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: [
              const AppTitle('multiplayer'),
              const NavigatorAppButton(
                'localPlay',
                routeName: GameScreen.routeName,
              ),
              userProvider.uid == ''
                  ? const CircularProgressIndicator()
                  : const NavigatorAppButton(
                      'onlinePlay',
                      routeName: OnlineScreen.routeName,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
