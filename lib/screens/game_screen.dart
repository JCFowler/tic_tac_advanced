import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../painters/line_painter.dart';
import '../providers/game_provider.dart';
import '../services/fire_service.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_number.dart';
import '../widgets/number_board.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game';

  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _numberController;
  late AnimationController _lineController;
  Animation<double>? _rotateAnimationFirst;
  Animation<double>? _rotateAnimationSecond;
  Animation<double>? _lineAnimation;
  final _fireService = FireService();

  @override
  void initState() {
    super.initState();

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _lineController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _lineAnimation = Tween(begin: 0.0, end: 1.0).animate(_lineController)
      ..addListener(() {
        setState(() {
          _progress = _lineAnimation!.value;
        });
      });

    _rotateAnimationFirst = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.linear),
    );
    _rotateAnimationSecond = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.linear),
    );

    Provider.of<GameProvider>(context, listen: false).initalizeGame(
      numberController: _numberController,
      lineController: _lineController,
      buildContext: context,
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  _addMark(int index, GameProvider game) {
    game.addMark(index);

    if (game.gameOver) {
      _lineController.reset();
      _lineController.forward().then(
            (_) => {
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
              ),
            },
          );
    }
  }

  Widget _backgroundGradient(GameProvider game) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (game.player == Player.Player1)
              ? [
                  Colors.white.withOpacity(0.3),
                  Colors.blue.withOpacity(1),
                ]
              : [
                  Colors.red.withOpacity(1),
                  Colors.white.withOpacity(0.3),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 1],
        ),
      ),
    );
  }

  Widget _gameBoard(GameProvider game) {
    return Expanded(
      child: CustomPaint(
        foregroundPainter: game.gameOver ? LinePainter(game, _progress) : null,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () => _addMark(index, game),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: game.lastMovePosition == index
                      ? Border.all(
                          color: game.player == Player.Player1
                              ? game.playerColor(Player.Player2)
                              : game.playerColor(Player.Player1),
                          width: 3,
                        )
                      : Border.all(
                          color: Colors.black54,
                        ),
                ),
                child: Center(
                  child: game.gameMarks[index] != null
                      ? RotationTransition(
                          turns: game.player == Player.Player2
                              ? _rotateAnimationFirst!
                              : _rotateAnimationSecond!,
                          child: GameNumber(game.gameMarks[index]!),
                        )
                      : const Text(''),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (ctx, game, _) => Stack(
            children: [
              _backgroundGradient(game),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RotationTransition(
                    turns: AlwaysStoppedAnimation(180 / 360),
                    child: NumberBoard(Player.Player2),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: game.gameDoc == ''
                          ? Row(
                              children: [
                                _gameBoard(game),
                                const ScoreBoard(),
                              ],
                            )
                          : StreamBuilder(
                              stream:
                                  _fireService.gameMatchStream(game.gameDoc),
                              builder: (ctx,
                                  AsyncSnapshot<DocumentSnapshot>
                                      streamSnapshot) {
                                if (streamSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final doc = streamSnapshot.data!;
                                var gameMarks =
                                    convertJsonToGameMarks(doc['gameMarks']);
                                print(gameMarks);

                                return Row(
                                  children: [
                                    _gameBoard(game),
                                    const ScoreBoard(),
                                  ],
                                );
                              },
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
