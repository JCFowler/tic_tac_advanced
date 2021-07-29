import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tic_tac_advanced/models/constants.dart';

import '../providers/game_provider.dart';

const strokeWidth = 6.0;
const doubleStrokeWidth = strokeWidth * 2.0;

class LinePainter extends CustomPainter {
  final GameProvider game;
  final double _progress;

  LinePainter(this.game, this._progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (game.gameOver) {
      final _dividedSize = size.width / 3.0;

      _paintLine(canvas, game.winningLine, _dividedSize, _progress, size);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._progress != _progress;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  void _paintLine(Canvas canvas, List<int> winningLine, double dividedSize,
      double progress, Size size) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round

      // ..maskFilter = MaskFilter.blur(BlurStyle.solid, convertRadiusToSigma(2))
      // ..color = Colors.purple.withOpacity(0.8);
      // ..color = Color(0xffFFD700)
      ..color = game.player == Player.Player1 ? Colors.blue : Colors.red;
    // ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.colorBurn);
    // ..shader = RadialGradient(
    //   // begin: Alignment.centerLeft,
    //   // end: Alignment.centerRight,
    //   center: Alignment.center,

    //   tileMode: TileMode.mirror,
    //   colors: [
    //     Colors.purple.shade300.withOpacity(0.8),
    //     Colors.purple.withOpacity(0.8),
    //     // Colors.purple.shade300,
    //     // Colors.red.withOpacity(0.9),
    //     // Colors.purple.shade300.withOpacity(0.9),
    //     // Colors.blue.withOpacity(0.9),
    //   ],
    //   // stops: const [0.4, 0.5, 0.6],
    // ).createShader(Offset.zero & size);

    final _blackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.black
      ..strokeCap = StrokeCap.round;

    var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0;

    var firstIndex = winningLine.first;
    var lastIndex = winningLine.last;

    Offset offX, offY;

    if (firstIndex % 3 == lastIndex % 3) {
      // Vertical Line
      x1 = x2 = firstIndex % 3 * dividedSize + dividedSize / 2;
      y1 = strokeWidth;
      y2 = dividedSize * 3 - strokeWidth;

      offX = Offset(x1, y1);
      offY = Offset(x2, y2 * progress);
    } else if (firstIndex ~/ 3 == lastIndex ~/ 3) {
      // Horizonal line
      x1 = strokeWidth;
      x2 = dividedSize * 3 - strokeWidth;
      y1 = y2 = firstIndex ~/ 3 * dividedSize + dividedSize / 2;

      offX = Offset(x1, y1);
      offY = Offset(x2 * progress, y2);
    } else {
      // Diagonal line (Top left -> Bottom right)
      if (firstIndex == 0) {
        x1 = y1 = doubleStrokeWidth;
        x2 = y2 = dividedSize * 3 - strokeWidth;

        offX = Offset(x1, y1);
        offY = Offset(x2 * progress, y2 * progress);
      } else {
        // Diagonal line (Top right -> Bottom left)
        x1 = dividedSize * 3 - strokeWidth;
        x2 = doubleStrokeWidth;
        y1 = doubleStrokeWidth;
        y2 = dividedSize * 3 - strokeWidth;

        offX = Offset(x1, y1);
        offY = Offset((-1 * (y2 - (x2)) * progress) + y2,
            (-1 * (x2 - (y2)) * progress) + x2);
      }
    }

    canvas.drawLine(offX, offY, _blackPaint);
    canvas.drawLine(offX, offY, _paint);
  }
}
