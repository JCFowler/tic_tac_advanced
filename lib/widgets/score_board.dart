import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/l10n.dart';
import '../providers/game_provider.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.8),
              Colors.blue.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 1],
          ),
        ),
        child: Consumer<GameProvider>(
          builder: (ctx, game, _) => Wrap(
            alignment: WrapAlignment.spaceAround,
            direction: Axis.vertical,
            runAlignment: WrapAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  game.scores[Player.Player2].toString(),
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  translate('wins', context),
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  game.scores[Player.Player1].toString(),
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
