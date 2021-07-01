import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_number.dart';
import '../widgets/number_board.dart';

const strokeWidth = 6.0;
const doubleStrokeWidth = strokeWidth * 2.0;

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  static const routeName = '/game';

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
// with SingleTickerProviderStateMixin
{
  // AnimationController? _animationController;
  // Animation<double>? _rotateAnimation;
  // var omg = false;

  // @override
  // void initState() {
  //   super.initState();

  //   _animationController = AnimationController(
  //     duration: Duration(milliseconds: 500),
  //     vsync: this,
  //   )..repeat();

  //   _rotateAnimation = Tween<double>(
  //     begin: 0.0,
  //     end: 360.0,
  //   ).animate(
  //     CurvedAnimation(parent: _animationController!, curve: Curves.linear),
  //   );
  // }

  // @override
  // void dispose() {
  //   _animationController!.dispose();
  //   super.dispose();
  // }

  _addMark(int index, GameProvider game) {
    game.addMark(index);
    // setState(() {
    //   // if (!omg) {
    //   //   _animationController!.animateBack(0);
    //   // } else {
    //   //   _animationController!.animateTo(180);
    //   // }
    // });

    if (game.gameOver) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Game finished!'),
          actions: [
            TextButton(
              onPressed: () {
                game.gameResart();
                Navigator.of(ctx).pop();
              },
              child: const Text('Play again?'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
                    stops: const [0, 1],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RotationTransition(
                    turns: AlwaysStoppedAnimation(180 / 360),
                    child: NumberBoard(Player.Player2),
                  ),
                  Expanded(
                    child: Center(
                      child: CustomPaint(
                        painter: GamePainter(game),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 9,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemBuilder: (ctx, index) {
                            return GestureDetector(
                              onTap: () => _addMark(index, game),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Colors.black,
                                )),
                                child: Center(
                                  // child: game.gameMarks[index] != null
                                  //     ? RotationTransition(
                                  //         turns: _rotateAnimation!,
                                  //         child: GameNumber(
                                  //             game.gameMarks[index]!))
                                  //     : Container(
                                  //         child: Text('Hi'),
                                  //       ),
                                  child: game.gameMarks[index] != null
                                      ? game.player == Player.Player2
                                          ? RotationTransition(
                                              turns:
                                                  const AlwaysStoppedAnimation(
                                                      180 / 360),
                                              child: GameNumber(
                                                  game.gameMarks[index]!),
                                            )
                                          : GameNumber(game.gameMarks[index]!)
                                      : Container(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const NumberBoard(Player.Player1),
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
    final orangePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.orange;

    _dividedSize = size.width / 3.0;

    if (game.gameOver) {
      drawWinningLine(canvas, game.winningLine, orangePaint);
    }
  }

  void drawWinningLine(Canvas canvas, List<int> winningLine, Paint paint) {
    var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0;

    var firstIndex = winningLine.first;
    var lastIndex = winningLine.last;

    if (firstIndex % 3 == lastIndex % 3) {
      // Vertical Line
      x1 = x2 = firstIndex % 3 * _dividedSize + _dividedSize / 2;
      y1 = strokeWidth;
      y2 = _dividedSize * 3 - strokeWidth;
    } else if (firstIndex ~/ 3 == lastIndex ~/ 3) {
      // Horizonal line
      x1 = strokeWidth;
      x2 = _dividedSize * 3 - strokeWidth;
      y1 = y2 = firstIndex ~/ 3 * _dividedSize + _dividedSize / 2;
    } else {
      if (firstIndex == 0) {
        x1 = y1 = doubleStrokeWidth;
        x2 = y2 = _dividedSize * 3 - strokeWidth;
      } else {
        x1 = _dividedSize * 3 - strokeWidth;
        x2 = doubleStrokeWidth;
        y1 = doubleStrokeWidth;
        y2 = _dividedSize * 3 - strokeWidth;
      }
    }

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
