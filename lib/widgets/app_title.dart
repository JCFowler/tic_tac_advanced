import 'package:flutter/material.dart';

import '../models/l10n.dart';

final colorizeTextStyle = TextStyle(
  fontSize: 50.0,
  fontFamily: 'Horizon',
  foreground: Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.purple,
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
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.purple.shade600;

    return Column(
      children: [
        SizedBox(height: deviceSize.height * 0.12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height: deviceSize.height * 0.15,
            child: FittedBox(
              child: Stack(
                children: [
                  Text(
                    translate(text, context),
                    style: TextStyle(
                      fontSize: 39,
                      foreground: paint,
                    ),
                  ),
                  Text(
                    translate(text, context),
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.blue[50],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: deviceSize.height * 0.05),
      ],
    );
  }
}
