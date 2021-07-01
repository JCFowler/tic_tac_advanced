import 'package:flutter/material.dart';

import '../models/mark.dart';

class GameNumber extends StatelessWidget {
  final Mark mark;

  GameNumber(this.mark);

  @override
  Widget build(BuildContext context) {
    print('Building GameNumber');
    return Text(
      mark.number.toString(),
      style: TextStyle(
        fontSize: 50,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = mark.color,
      ),
    );
  }
}
