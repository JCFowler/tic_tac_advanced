import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/custom_app_bar.dart';

import '../models/mark.dart';
import '../widgets/number_board.dart';

const STROKE_WIDTH = 6.0;
const HALF_STROKE_WIDTH = STROKE_WIDTH / 2.0;
const DOUBLE_STROKE_WIDTH = STROKE_WIDTH * 2.0;

class GameScreen extends StatefulWidget {
  static const routeName = '/game';

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  _addMark(double x, double y, GameProvider game) {
    double _dividedSize = GamePainter.getDividedSize();
    game.addMark(x ~/ _dividedSize + (y ~/ _dividedSize) * 3);

    if (game.gameOver) {
      showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Game finished!'),
          actions: [
            TextButton(
              onPressed: () {
                game.gameResart();
                Navigator.of(ctx).pop();
              },
              child: Text('Play again?'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (ctx, game, _) => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (game.player == Player.Player1)
                        ? [
                            Colors.red.withOpacity(0.3),
                            Colors.blue.withOpacity(0.8),
                          ]
                        : [
                            Colors.red.withOpacity(0.8),
                            Colors.blue.withOpacity(0.3),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 1],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RotationTransition(
                    turns: AlwaysStoppedAnimation(180 / 360),
                    child: NumberBoard(Player.Player2),
                  ),
                  Center(
                    child: GestureDetector(
                      onTapUp: (TapUpDetails details) {
                        setState(() {
                          _addMark(
                            details.localPosition.dx,
                            details.localPosition.dy,
                            game,
                          );
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          child: CustomPaint(
                            painter: GamePainter(game),
                          ),
                        ),
                      ),
                    ),
                  ),
                  NumberBoard(Player.Player1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  static double _dividedSize = 0.0;
  GameProvider game;

  GamePainter(this.game);

  static double getDividedSize() => _dividedSize;

  @override
  void paint(Canvas canvas, Size size) {
    print('rerun');
    final blackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = STROKE_WIDTH
      ..color = Colors.black;

    final orangePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = STROKE_WIDTH
      ..color = Colors.orange;

    _dividedSize = size.width / 3.0;

    canvas.drawLine(
      Offset(STROKE_WIDTH, _dividedSize - HALF_STROKE_WIDTH),
      Offset(size.width - STROKE_WIDTH, _dividedSize - HALF_STROKE_WIDTH),
      blackPaint,
    );

    canvas.drawLine(
      Offset(STROKE_WIDTH, _dividedSize * 2 - HALF_STROKE_WIDTH),
      Offset(size.width - STROKE_WIDTH, _dividedSize * 2 - HALF_STROKE_WIDTH),
      blackPaint,
    );

    canvas.drawLine(
      Offset(_dividedSize - HALF_STROKE_WIDTH, -STROKE_WIDTH),
      Offset(_dividedSize - HALF_STROKE_WIDTH, size.height - STROKE_WIDTH),
      blackPaint,
    );

    canvas.drawLine(
      Offset(_dividedSize * 2 - HALF_STROKE_WIDTH, -STROKE_WIDTH),
      Offset(_dividedSize * 2 - HALF_STROKE_WIDTH, size.height - STROKE_WIDTH),
      blackPaint,
    );

    game.gameMarks.forEach((index, mark) {
      draw(canvas, index, mark, blackPaint, game.playerColor(mark.player));
    });

    if (game.gameOver) {
      drawWinningLine(canvas, game.winningLine, orangePaint);
    }
  }

  void draw(Canvas canvas, int index, Mark mark, Paint paint, Color color) {
    double left = (index % 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2.9;
    double top = (index ~/ 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 1.5;
    double numberSize = _dividedSize - DOUBLE_STROKE_WIDTH * 4;

    final textStyle = TextStyle(
      // color: color,
      fontSize: numberSize,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
    final textSpan = TextSpan(
      text: mark.number.toString(),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 20,
      maxWidth: numberSize,
    );

    final offset = Offset(left, top);
    textPainter.paint(canvas, offset);
  }

  void drawWinningLine(Canvas canvas, List<int> winningLine, Paint paint) {
    double x1 = 0, x2 = 0, y1 = 0, y2 = 0;

    int firstIndex = winningLine.first;
    int lastIndex = winningLine.last;

    if (firstIndex % 3 == lastIndex % 3) {
      // Vertical Line
      x1 = x2 = firstIndex % 3 * _dividedSize + _dividedSize / 2;
      y1 = STROKE_WIDTH;
      y2 = _dividedSize * 3 - STROKE_WIDTH;
    } else if (firstIndex ~/ 3 == lastIndex ~/ 3) {
      // Horizonal line
      x1 = STROKE_WIDTH;
      x2 = _dividedSize * 3 - STROKE_WIDTH;
      y1 = y2 = firstIndex ~/ 3 * _dividedSize + _dividedSize / 2;
    } else {
      if (firstIndex == 0) {
        x1 = y1 = DOUBLE_STROKE_WIDTH;
        x2 = y2 = _dividedSize * 3 - STROKE_WIDTH;
      } else {
        x1 = _dividedSize * 3 - STROKE_WIDTH;
        x2 = DOUBLE_STROKE_WIDTH;
        y1 = DOUBLE_STROKE_WIDTH;
        y2 = _dividedSize * 3 - STROKE_WIDTH;
      }
    }

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
