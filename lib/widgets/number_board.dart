import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../providers/game_provider.dart';
import 'game_board_number.dart';

class NumberBoard extends StatelessWidget {
  final Player player;
  final String username;

  const NumberBoard(
    this.player,
    this.username, {
    Key? key,
  }) : super(key: key);

  bool _canSelectNumber(GameProvider game, bool used) {
    if (game.gameType != GameType.Local && player == Player.Player2) {
      return false;
    }

    if (player == game.player && !used && !game.gameOver) {
      return true;
    }

    return false;
  }

  Widget _numberWidget(int key, bool value, double width) {
    return GameBoardNumber(
      number: key,
      player: player,
      used: key == 1 ? false : value,
      width: width / 7,
    );
  }

  List<Widget> _getNumbers(
      Map<int, bool> numbers, BuildContext context, GameProvider game) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> list = [];
    numbers.forEach((key, value) {
      list.add(
        _canSelectNumber(game, key == 1 ? false : value)
            ? Draggable<int>(
                data: key,
                maxSimultaneousDrags: 1,
                onDragStarted: () => game.changeSelectedNumber(key),
                onDraggableCanceled: (_, __) => game.changeSelectedNumber(-1),
                ignoringFeedbackSemantics: false,
                child: _numberWidget(key, value, width),
                feedback: Material(
                  child: player == Player.Player1
                      ? _numberWidget(key, value, width)
                      : RotationTransition(
                          turns: const AlwaysStoppedAnimation(180 / 360),
                          child: _numberWidget(key, value, width)),
                ),
                childWhenDragging: _numberWidget(key, value, width),
              )
            : _numberWidget(key, value, width),
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (username != '')
          Container(
            alignment: Alignment.center,
            height: 25,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(1000, 200),
                topRight: Radius.elliptical(1000, 200),
              ),
            ),
            child: player == Player.Player1
                ? Text(username)
                : RotationTransition(
                    turns: const AlwaysStoppedAnimation(180 / 360),
                    child: Text(username),
                  ),
          ),
        Consumer<GameProvider>(
          builder: (ctx, game, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNumbers(game.numbers(player), context, game),
          ),
        ),
      ],
    );
  }
}
