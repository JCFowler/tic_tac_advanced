import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/app_button.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
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
          SizedBox(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 150,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Tic Tac\nAdvanced',
                          speed: const Duration(milliseconds: 200),
                          textStyle: colorizeTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      isRepeatingAnimation: false,
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: Column(
                    children: [
                      AppButton(
                        'Play',
                        () => Navigator.of(context).pushNamed(
                          GameScreen.routeName,
                        ),
                      ),
                      AppButton(
                        'Settings',
                        () => Navigator.of(context).pushNamed(
                          SettingsScreen.routeName,
                        ),
                      ),
                      AppButton(
                        'Test',
                        () => Navigator.of(context).pushNamed(
                          'test',
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.helloWorld)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
