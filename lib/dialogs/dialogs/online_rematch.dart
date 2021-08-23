import 'package:flutter/material.dart';

import '../../helpers/translate_helper.dart';
import '../../models/constants.dart';
import '../../models/game_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/spinning_icon.dart';
import '../../widgets/waiting_text.dart';
import '../base_dialog_components.dart';

Future<dynamic> showOnlineRematchDialog(
  BuildContext context,
  GameProvider game,
  GameModel model, {
  required bool won,
  required Stream<GameModel?> stream,
  bool barrierDismissible = false,
}) {
  return basicDialogComponent(
    context,
    barrierDismissible: barrierDismissible,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getFaceIcon(context, won),
            Text(
              translate(game.player == Player.Player1 ? 'won' : 'lost'),
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).accentColor,
              ),
            ),
            _getFaceIcon(context, won),
          ],
        ),
        StatefulBuilder(
          builder: (builderContext, setState) {
            return StreamBuilder(
              stream: stream,
              builder: (ctx, AsyncSnapshot<GameModel?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final gameData = snapshot.data!;

                var newNames = MultiplayerNames.getNames(gameData);

                newNames ??= game.multiplayerNames;

                bool? player2Answer, player1Answer;

                if (newNames!.hostPlayerUid == game.uid) {
                  player1Answer = newNames.hostRematch;
                  player2Answer = newNames.addedRematch;
                } else {
                  player2Answer = newNames.hostRematch;
                  player1Answer = newNames.addedRematch;
                }

                if (player1Answer == true && player2Answer == true) {
                  // setTimeout(() {
                  Navigator.pop(context);
                  game.restartOnlineGame(runFirebase: false);
                  // }, 2000);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _getRematchAnswer(
                            context,
                            game.getStaticUsername(Player.Player2),
                            game.playerColor(Player.Player2),
                            player2Answer,
                          ),
                          _getRematchAnswer(
                            context,
                            game.getStaticUsername(Player.Player1),
                            game.playerColor(Player.Player1),
                            player1Answer,
                          ),
                        ],
                      ),
                    ),
                    ..._getRematchButtons(
                        context, game, player1Answer, player2Answer),
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

Widget _getFaceIcon(BuildContext context, bool won) {
  var icon =
      won ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied;

  return SpinningIcon(
    icon: Icon(
      icon,
      size: 40,
      color: Theme.of(context).accentColor,
    ),
  );
}

Widget _getRematchAnswer(
  BuildContext context,
  String username,
  Color color,
  bool? rematchAnswer,
) {
  BoxDecoration decoration;
  Icon icon;

  if (rematchAnswer == null) {
    decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    );
    icon = Icon(
      Icons.help_outline,
      color: Colors.grey.shade500,
    );
  } else if (rematchAnswer) {
    decoration = BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(10),
    );
    icon = const Icon(
      Icons.check,
      color: Colors.white,
    );
  } else {
    decoration = BoxDecoration(
      color: Colors.red,
      border: Border.all(color: Colors.red),
      borderRadius: BorderRadius.circular(10),
    );
    icon = const Icon(
      Icons.close,
      color: Colors.white,
    );
  }
  return Column(
    children: [
      Text(
        username,
        style: TextStyle(
          color: color,
          fontSize: 16,
        ),
      ),
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          height: 70,
          width: 70,
          decoration: decoration,
          child: FittedBox(
            child: icon,
          ),
        ),
      ),
    ],
  );
}

List<Widget> _getRematchButtons(
  BuildContext context,
  GameProvider game,
  bool? player1Answer,
  bool? player2Answer,
) {
  List<Widget> widgets = [];

  if ((player2Answer == null || player2Answer) && player1Answer != false) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          color: Colors.grey.shade50,
          width: double.infinity,
          height: 40,
          padding: EdgeInsets.zero,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: game.multiplayerData!.addedPlayer != null
                  ? player1Answer != null
                      ? WaitingText(
                          translate('waitingFor',
                              args: game.getPlayerUsername(Player.Player2)),
                        )
                      : Text(
                          translate('rematch'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 20,
                          ),
                        )
                  : Text(
                      translate('playerQuit'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  } else if (player1Answer != false) {
    widgets.add(
      PrimaryButton(
        translate('hostNewGame'),
        onPressed: () {
          Navigator.pop(context);
          game.hostGame(context, popGameScreen: true);
        },
      ),
    );
  }

  if (player1Answer == null && (player2Answer == null || player2Answer)) {
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PrimaryButton(
            translate('no'),
            expanded: true,
            backgroundColor: Theme.of(context).errorColor,
            onPressed: () => game.updateRematch(false),
          ),
          const SizedBox(width: 10),
          PrimaryButton(
            translate('yes'),
            expanded: true,
            onPressed: () {
              bool bothYes = false;
              if (game.multiplayerData!.hostRematch == true ||
                  game.multiplayerData!.addedRematch == true) {
                bothYes = true;
              }

              game.updateRematch(true).then((_) {
                if (bothYes) {
                  game.restartOnlineGame();
                }
              });
            },
          ),
        ],
      ),
    );
  } else {
    widgets.add(
      PrimaryButton(
        translate('quit'),
        backgroundColor: Theme.of(context).errorColor,
        onPressed: () {
          var count = 0;
          Navigator.popUntil(context, (route) {
            return count++ == 2;
          });
          game.leaveGame(autoOpen: false);
        },
      ),
    );
  }
  return widgets;
}
