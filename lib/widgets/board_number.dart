import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../providers/game_provider.dart';

class BoardNumber extends StatelessWidget {
  final int number;
  final Player player;
  final bool used;
  final double width;

  const BoardNumber({
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
      onTap: () => game.canSelectNumber(player, used)
          ? game.changeSelectedNumber(number)
          : null,
      child: Card(
        color: selected
            ? game.playerColor(player)
            : Theme.of(context).scaffoldBackgroundColor,
        margin: const EdgeInsets.all(3),
        child: Container(
          width: width - 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              number.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                color: used
                    ? Colors.grey
                    : selected
                        ? Theme.of(context).scaffoldBackgroundColor
                        : game.playerColor(player),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
