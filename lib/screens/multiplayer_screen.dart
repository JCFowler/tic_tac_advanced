import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/app_title.dart';
import 'game_screen.dart';

var colorizeTextStyle = TextStyle(
  fontSize: 50.0,
  fontFamily: 'Horizon',
  foreground: Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.blue
    ..shader = const LinearGradient(
      colors: [
        Colors.red,
        Colors.red,
        Colors.purple,
        Colors.blue,
        Colors.blue,
      ],
    ).createShader(
      Rect.fromCircle(
        center: const Offset(150.0, 55.0),
        radius: 200.0,
      ),
    ),
);

class MultiplayerScreen extends StatelessWidget {
  static const routeName = '/multiplayer-select';
  const MultiplayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.5),
                  Colors.red.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                const AppTitle('Multiplayer'),
                AppButton(
                  'Local Play',
                  () => Navigator.of(context).pushNamed(
                    GameScreen.routeName,
                  ),
                ),
                AppButton(
                  'Online Play',
                  () => Navigator.of(context).pushNamed(
                    GameScreen.routeName,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
