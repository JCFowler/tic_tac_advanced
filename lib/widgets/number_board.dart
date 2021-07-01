import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'game_number.dart';

class NumberBoard extends StatelessWidget {
  final Player player;

  NumberBoard(this.player);

  List<Widget> _getNumbers(Map<int, bool> numbers, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> list = [];
    numbers.forEach((key, value) {
      list.add(
        GameNumber(
          key,
          player,
          value,
          width / 7,
        ),
      );
    });
    return list;
  }

  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(8.0),
      child: Consumer<GameProvider>(
        builder: (ctx, game, _) => Container(
          // width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNumbers(game.numbers(player), context),
          ),
        ),
      ),
    );
  }
}
