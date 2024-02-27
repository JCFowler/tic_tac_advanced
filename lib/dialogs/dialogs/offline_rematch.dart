import 'package:flutter/material.dart';
import 'package:tic_tac_advanced/widgets/score_board.dart';

import '../../helpers/translate_helper.dart';
import '../../models/constants.dart';
import '../../widgets/primary_button.dart';
import '../base_dialog_components.dart';

Future<bool?> showOfflineRematchDialog(
  BuildContext context, {
  required Player wonPlayer,
  required Color titleColor,
  required int? player1Score,
  required int? player2Score,
}) {
  return basicDialogComponent(
    context,
    child: Column(
      children: [
        Text(
          translate(
              wonPlayer == Player.Player1 ? 'bluePlayerWon' : 'redPlayerWon'),
          style: TextStyle(
            fontSize: 28,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        ScoreBoard(player1Score: player1Score, player2Score: player2Score),
        const SizedBox(height: 30),
        Text(translate('playAgain'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PrimaryButton(
              translate('no'),
              expanded: true,
              fontSize: 24,
              backgroundColor: Theme.of(context).colorScheme.error,
              onPressed: () => Navigator.pop(context, false),
            ),
            PrimaryButton(
              translate('yes'),
              expanded: true,
              fontSize: 24,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}
