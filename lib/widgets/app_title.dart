import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

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

class AppTitle extends StatelessWidget {
  final String text;

  const AppTitle(
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(height: deviceSize.height * 0.15),
          SizedBox(
            height: deviceSize.height * 0.15,
            child: FittedBox(
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    text,
                    speed: const Duration(milliseconds: 150),
                    textStyle: colorizeTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
          ),
          SizedBox(height: deviceSize.height * 0.05),
        ],
      ),
    );
  }
}
