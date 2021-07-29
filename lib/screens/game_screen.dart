import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_dialog.dart';
import '../models/constants.dart';
import '../painters/line_painter.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
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
  var _docId = '';
  var _userId = '';
  StreamSubscription? _gameStream;
  var _showingDialog = false;
  var hover = -1;

  Future<bool> _onWillPop() async {
    var result = await showAlertDialog(
      context,
      'Exit Game',
      content: 'Are you sure you want to quit the game?',
    );

    if (result) {
      if (_docId != '') {
        if (_gameStream != null) _gameStream!.cancel();
        _fireService.leaveGame(_docId, _userId);
      }
    }

    return result;
  }

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

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    gameProvider.initalizeGame(
      numberController: _numberController,
      lineController: _lineController,
      buildContext: context,
    );

    if (gameProvider.gameType == GameType.Online) {
      _userId = userProvider.uid;
      _gameStream = _fireService
          .gameMatchStream(gameProvider.gameDoc)
          .listen((gameModel) {
        _docId = gameProvider.gameDoc;

        if (gameModel != null) {
          gameProvider.setMultiplayerData(gameModel);
          if (gameModel.addedPlayer == null) {
            showLoadingDialog(context, 'Waiting for new player...')
                .then((result) {
              if (result == 'cancel') {
                _fireService.deleteGame(_userId);
                Navigator.of(context).pop();
              }
            });
            _showingDialog = true;
            gameProvider.gameResart(
                hostPlayerGoesFirst: gameModel.hostPlayerGoesFirst);
          } else {
            if (_showingDialog) {
              _showingDialog = false;
              Navigator.of(context).pop();
            }
            if (gameModel.lastMove != null) {
              gameProvider.addOnlineMark(gameModel.lastMove!);
            }
          }
        }
      });
    }
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (game.player == Player.Player1)
              ? [
                  Theme.of(context).scaffoldBackgroundColor,
                  Colors.blue.withOpacity(1),
                ]
              : [
                  Colors.red.withOpacity(1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 0.9],
        ),
      ),
    );
  }

  BoxBorder changeBorder(GameProvider game, int index) {
    if (hover == index) {
      return Border.all(
        color: game.player == Player.Player1
            ? game.playerColor(Player.Player1)
            : game.playerColor(Player.Player2),
        width: 3,
      );
    } else if (game.gameOver && game.lastMovePosition == index) {
      return Border.all(
        color: game.player == Player.Player1
            ? game.playerColor(Player.Player1)
            : game.playerColor(Player.Player2),
        width: 3,
      );
    } else if (game.lastMovePosition == index) {
      return Border.all(
        color: game.player == Player.Player1
            ? game.playerColor(Player.Player2)
            : game.playerColor(Player.Player1),
        width: 3,
      );
    } else {
      return Border.all(
        color: Colors.black54,
      );
    }
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
              child: DragTarget<int>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: changeBorder(game, index),
                    ),
                    child: Center(
                      child: game.gameMarks[index] != null
                          ? game.gameDoc == ''
                              ? RotationTransition(
                                  turns: game.player == Player.Player2
                                      ? _rotateAnimationFirst!
                                      : _rotateAnimationSecond!,
                                  child: GameNumber(game.gameMarks[index]!),
                                )
                              : GameNumber(game.gameMarks[index]!)
                          : const Text(''),
                    ),
                  );
                },
                onAccept: (int data) {
                  _addMark(index, game);
                  setState(() {
                    hover = -1;
                  });
                },
                onLeave: (int? data) {
                  setState(() {
                    hover = -1;
                  });
                },
                onWillAccept: (int? data) {
                  if (game.gameMarks[index] == null ||
                      data! > game.gameMarks[index]!.number) {
                    setState(() {
                      hover = index;
                    });
                  }
                  return true;
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const GameAppBar(),
        body: SafeArea(
          child: Consumer<GameProvider>(
            builder: (ctx, game, _) => Stack(
              children: [
                _backgroundGradient(game),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RotationTransition(
                      turns: const AlwaysStoppedAnimation(180 / 360),
                      child: NumberBoard(Player.Player2,
                          game.getPlayerUsername(Player.Player2)),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            _gameBoard(game),
                            const ScoreBoard(),
                          ],
                        ),
                      ),
                    ),
                    NumberBoard(
                        Player.Player1, game.getPlayerUsername(Player.Player1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
