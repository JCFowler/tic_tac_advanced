import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/dialogs/alert.dart';
import '../helpers/translate_helper.dart';
import '../models/constants.dart';
import '../providers/ad_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_number.dart';
import '../widgets/number_board.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game';

  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _numberController;
  Animation<double>? _rotateAnimationFirst;
  Animation<double>? _rotateAnimationSecond;
  var hover = -1;

  Future<bool> _onWillPop() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final adProvider = Provider.of<AdProvider>(context, listen: false);

    if (gameProvider.winningLine.isNotEmpty) {
      adProvider.showInterstitialAd();
      return true;
    }

    var result = await showAlertDialog(
      context,
      translate('exitGame'),
      content: translate('areYouSureToQuit'),
    );

    if (result != null && result) {
      if (context.mounted) {
        gameProvider.leaveGame();
        adProvider.showInterstitialAd();
      }
    }
    return result ?? false;
  }

  @override
  void initState() {
    super.initState();

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

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
    gameProvider.initalizeGame(
      numberController: _numberController,
      buildContext: context,
    );

    if (gameProvider.gameDoc.isNotEmpty) {
      gameProvider.startGameStream();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<GameProvider>(
        builder: (ctx, game, _) => Scaffold(
          appBar: GameAppBar(
            gameScreen: true,
            // To change the color of the top part of the screen.
            backgroundColor: game.player == Player.Player1
                ? Theme.of(context).scaffoldBackgroundColor
                : game.playerColor(Player.Player2),
          ),
          body: Container(
            // To change the color of the bottom part of the screen.
            color: game.player == Player.Player1
                ? game.playerColor(Player.Player1)
                : Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Stack(
                children: [
                  _backgroundGradient(game),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RotationTransition(
                        turns: const AlwaysStoppedAnimation(180 / 360),
                        child: NumberBoard(
                          Player.Player2,
                          game.getPlayerUsername(Player.Player2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: _gameBoard(game),
                      ),
                      NumberBoard(
                        Player.Player1,
                        game.getPlayerUsername(Player.Player1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  BoxBorder _changeBorder(GameProvider game, int index) {
    if (game.gameOver) {
      for (var line in game.winningLine) {
        if (index == line) {
          return Border.all(
            color: Colors.white,
            width: 5,
          );
        }
      }
    }
    if (hover == index || game.gameOver && game.lastMovePosition == index) {
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

  Color _getGameBoxColors(GameProvider game, int index) {
    if (game.gameOver) {
      for (var line in game.winningLine) {
        if (index == line) {
          return game.playerColor(game.player);
        }
      }
    }
    return Colors.white;
  }

  Duration _animationDuration(GameProvider game, int index) {
    if (hover != -1) return const Duration(milliseconds: 0);

    if (game.gameOver) {
      for (var i = 0; i < game.winningLine.length; i++) {
        if (index == game.winningLine[i]) {
          return Duration(milliseconds: 250 * (i + 1));
        }
      }
    }

    return const Duration(milliseconds: 200);
  }

  Widget _gameBoard(GameProvider game) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (ctx, index) {
        return GestureDetector(
          onTap: () => game.addMark(index),
          child: DragTarget<int>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return AnimatedContainer(
                curve: Curves.elasticIn,
                duration: _animationDuration(game, index),
                decoration: BoxDecoration(
                  color: _getGameBoxColors(game, index),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: _changeBorder(game, index),
                ),
                child: Center(
                  child: game.gameMarks[index] != null
                      ? game.gameDoc == ''
                          ? RotationTransition(
                              turns: game.player == Player.Player2
                                  ? _rotateAnimationFirst!
                                  : _rotateAnimationSecond!,
                              child: GameNumber(
                                game.gameMarks[index]!,
                                game.gameOver &&
                                    game.winningLine.contains(index),
                              ),
                            )
                          : GameNumber(
                              game.gameMarks[index]!,
                              game.gameOver && game.winningLine.contains(index),
                            )
                      : const Text(''),
                ),
              );
            },
            onAcceptWithDetails: (details) {
              game.addMark(index);
              setState(() {
                hover = -1;
              });
            },
            onLeave: (int? data) {
              setState(() {
                hover = -1;
              });
            },
            onWillAcceptWithDetails: (details) {
              if (game.gameMarks[index]?.player != game.player &&
                  (game.gameMarks[index] == null ||
                      details.data > game.gameMarks[index]!.number &&
                          game.lastMovePosition != index)) {
                setState(() {
                  hover = index;
                });
              }
              return true;
            },
          ),
        );
      },
    );
  }
}
