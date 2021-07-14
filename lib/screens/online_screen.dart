import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';

class OnlineScreen extends StatelessWidget {
  static const routeName = '/online';

  const OnlineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Center(
          child: Consumer<UserProvider>(
            builder: (ctx, userProvider, _) => Column(
              children: [
                const AppTitle('Online2'),
                Text(userProvider.username),
                const NavigatorAppButton(
                  'localPlay',
                  routeName: GameScreen.routeName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
