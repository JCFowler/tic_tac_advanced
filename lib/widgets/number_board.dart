import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'game_board_number.dart';

class NumberBoard extends StatelessWidget {
  final Player player;

  const NumberBoard(
    this.player, {
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
    return Consumer<GameProvider>(
      builder: (ctx, game, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _getNumbers(game.numbers(player), context),
      ),
    );
  }
}
