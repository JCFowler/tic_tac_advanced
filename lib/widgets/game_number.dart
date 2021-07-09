import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mark.dart';
import '../providers/game_provider.dart';

class GameNumber extends StatelessWidget {
  final Mark mark;

  const GameNumber(
    this.mark, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (ctx, game, _) => Text(
        mark.number != -1 ? mark.number.toString() : '',
        style: TextStyle(
          fontSize: 50,
          color: game.playerColor(mark.player),
        ),
      ),
    );
  }
}
