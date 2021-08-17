import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/snack_bar_helper.dart';
import '../main.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../providers/game_provider.dart';
import 'loading_bar.dart';

class InviteSnackBarLayout extends StatelessWidget {
  final GameModel game;
  final int? milliseconds;
  final bool reset;

  const InviteSnackBarLayout(
    this.game, {
    this.milliseconds,
    this.reset = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gameProvider = Provider.of<GameProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person),
                FittedBox(
                  child: Text(
                    '${game.hostPlayer} Invited you.',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    gameProvider.declinePrivateGame(game.id);
                    hideSnackBar();
                  },
                ),
                TextButton(
                  child: FittedBox(
                    child: Text(
                      'Join',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (gameProvider.gameDoc.isNotEmpty ||
                        gameProvider.gameType != GameType.None) {
                      await gameProvider.leaveGame(popScreen: true);
                    }
                    gameProvider.joinGame(navigatorKey.currentContext!, game);
                  },
                ),
              ],
            ),
          ),
          if (milliseconds != null)
            LoadingBar(
              milliseconds!,
              hideSnackBar: true,
              reset: reset,
            ),
        ],
      ),
    );
  }
}
