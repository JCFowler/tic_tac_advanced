import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class GameNumber extends StatelessWidget {
  final int number;
  final Player player;
  final bool used;
  final double width;

  GameNumber(
    this.number,
    this.player,
    this.used,
    this.width,
  );

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return GestureDetector(
      onTap: () => (player == game.player && !used && !game.gameOver)
          ? game.changeSelectedNumber(number)
          : null,
      child: Container(
        width: width,
        // Need to add color, or the padding wont take for the tap gesture.
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Text(
          number.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            color: used
                ? Colors.grey
                : game.selectedNumber == number && player == game.player
                    ? Colors.purple
                    : game.playerColor(player),
          ),
        ),
      ),
    );
  }
}
