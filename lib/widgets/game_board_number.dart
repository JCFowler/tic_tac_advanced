import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class GameBoardNumber extends StatelessWidget {
  final int number;
  final Player player;
  final bool used;
  final double width;

  const GameBoardNumber({
    Key? key,
    required this.number,
    required this.player,
    required this.used,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final selected = game.selectedNumber == number && player == game.player;
    return GestureDetector(
      onTap: () => (player == game.player && !used && !game.gameOver)
          ? game.changeSelectedNumber(number)
          : null,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: selected
              ? game.playerColor(player)
              : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Text(
          number.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            color: used
                ? Colors.grey
                : selected
                    ? Theme.of(context).scaffoldBackgroundColor
                    : game.playerColor(player),
          ),
        ),
      ),
    );
  }
}
