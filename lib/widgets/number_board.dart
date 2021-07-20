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

  List<Widget> _getNumbers(Map<int, bool> numbers, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> list = [];
    numbers.forEach((key, value) {
      list.add(
        GameBoardNumber(
          number: key,
          player: player,
          used: key == 1 ? false : value,
          width: width / 7,
        ),
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
            children: _getNumbers(game.numbers(player), context),
          ),
        ),
      ],
    );
  }
}
