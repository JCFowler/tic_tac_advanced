import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/check_version.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'multiplayer_screen.dart';
import 'single_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (userProvider.uid == '') {
      userProvider.createAnonymousUser().then((userId) {
        if (userId != null) {
          gameProvider.startPrivateGameStream(userId);
        }
      });
    }
    checkVersion(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Column(
          children: [
            SizedBox(height: deviceSize.height * 0.1),
            SizedBox(
              height: deviceSize.height * 0.4,
              child: Image.asset(
                'assets/images/tic-tac-dark.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
