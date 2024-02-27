import 'package:flutter/material.dart';

import '../helpers/translate_helper.dart';

class ScoreBoard extends StatelessWidget {
  final int? player1Score;
  final int? player2Score;

  const ScoreBoard(
      {Key? key, required this.player1Score, required this.player2Score})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0, 1],
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              '$player1Score',
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 20,
              ),
            ),
            Text(
              translate('wins'),
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            Text(
              '$player2Score',
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
