import 'dart:math';

import 'package:flutter/material.dart';

class X1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // create a bounding square, based on the centre and radius of the arc
    Rect rect = Rect.fromCircle(
      center: const Offset(165.0, 55.0),
      radius: 180.0,
    );

    // a fancy rainbow gradient
    final Gradient gradient = RadialGradient(
      colors: <Color>[
        Colors.green.withOpacity(1.0),
        Colors.green.withOpacity(0.3),
        Colors.yellow.withOpacity(0.2),
        Colors.red.withOpacity(0.1),
        Colors.red.withOpacity(0.0),
      ],
      stops: const [
        0.0,
        0.5,
        0.7,
        0.9,
        1.0,
      ],
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    // and draw an arc
    canvas.drawArc(rect, pi / 4, pi * 3 / 4, true, paint);
  }

  @override
  bool shouldRepaint(X1Painter oldDelegate) {
    return true;
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arcs etc')),
      body: CustomPaint(
        painter: X1Painter(),
      ),
    );
  }
}
