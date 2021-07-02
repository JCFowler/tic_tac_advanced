import 'dart:ui';

import 'package:flutter/material.dart';

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

      _paintLine(canvas, game.winningLine, _dividedSize, _progress);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._progress != _progress;
  }

  void _paintLine(Canvas canvas, List<int> winningLine, double dividedSize,
      double progress) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.orange;

    var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0;

    var firstIndex = winningLine.first;
    var lastIndex = winningLine.last;

    if (firstIndex % 3 == lastIndex % 3) {
      // Vertical Line
      x1 = x2 = firstIndex % 3 * dividedSize + dividedSize / 2;
      y1 = strokeWidth;
      y2 = dividedSize * 3 - strokeWidth;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2 * progress), _paint);
    } else if (firstIndex ~/ 3 == lastIndex ~/ 3) {
      // Horizonal line
      x1 = strokeWidth;
      x2 = dividedSize * 3 - strokeWidth;
      y1 = y2 = firstIndex ~/ 3 * dividedSize + dividedSize / 2;

      canvas.drawLine(Offset(x1, y1), Offset(x2 * progress, y2), _paint);
    } else {
      // Diagonal line (Top left -> Bottom right)
      if (firstIndex == 0) {
        x1 = y1 = doubleStrokeWidth;
        x2 = y2 = dividedSize * 3 - strokeWidth;
        canvas.drawLine(
            Offset(x1, y1), Offset(x2 * progress, y2 * progress), _paint);
      } else {
        // Diagonal line (Top right -> Bottom left)
        x1 = dividedSize * 3 - strokeWidth;
        x2 = doubleStrokeWidth;
        y1 = doubleStrokeWidth;
        y2 = dividedSize * 3 - strokeWidth;

        canvas.drawLine(
          Offset(x1, y1),
          Offset((-1 * (y2 - (x2)) * progress) + y2,
              (-1 * (x2 - (y2)) * progress) + x2),
          _paint,
        );
      }
    }
  }
}
