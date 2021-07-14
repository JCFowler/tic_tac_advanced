import 'package:flutter/material.dart';

import '../providers/game_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import 'multiplayer_screen.dart';
import 'settings_screen.dart';
import 'single_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: [
              const AppTitle('Tic Tac\nAdvanced'),
              Expanded(
                child: Column(
                  children: const [
                    NavigatorAppButton(
                      'singlePlayer',
                      routeName: SinglePlayerScreen.routeName,
                    ),
                    NavigatorAppButton(
                      'multiplayer',
                      routeName: MultiplayerScreen.routeName,
                      aiGameType: AiType.None,
                    ),
                    NavigatorAppButton(
                      'settings',
                      routeName: SettingsScreen.routeName,
                    ),
                    NavigatorAppButton(
                      'Test',
                      routeName: 'test',
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    // print(await auth.doesUsernameExist('Guest1'));
                    // FirebaseFirestore.instance
                    //     .collection('testing')
                    //     .snapshots()
                    //     .listen((data) {
                    //   data.docs.forEach((element) {
                    //     print(element['test']);
                    //   });
                    // });
                  },
                  child: Text("Test")),
            ],
          ),
        ),
      ),
    );
  }
}
