import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../models/l10n.dart';
import '../providers/game_provider.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AppButton(
    this.text,
    this.onTap, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.black
      ..shader = LinearGradient(colors: [
        Colors.red,
        Colors.red,
        Colors.purple[400]!,
        Colors.blue,
        Colors.blue,
      ]).createShader(
        Rect.fromCircle(
          center: const Offset(150.0, 55.0),
          radius: 200.0,
        ),
      );

    final translatedText = translate(text, context);

    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FittedBox(
          child: Stack(
            children: <Widget>[
              // Stroked text as border.
              Text(
                translatedText,
                style: TextStyle(
                  fontSize: 40,
                  foreground: paint,
                ),
              ),
              // Solid text as fill.
              Text(
                translatedText,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue[50],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigatorAppButton extends StatelessWidget {
  final String text;
  final String routeName;
  final GameType? gameType;

  const NavigatorAppButton(
    this.text, {
    Key? key,
    required this.routeName,
    this.gameType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text,
      () {
        if (gameType != null) {
          Provider.of<GameProvider>(context, listen: false)
              .setGameType(gameType!);
        }
        Navigator.of(context).pushNamed(routeName);
      },
    );
  }
}
