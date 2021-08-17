import 'package:flutter/material.dart';

import '../main.dart';
import '../models/game_model.dart';
import '../widgets/invite_snack_bar.dart';

hideSnackBar() {
  var currentContext = navigatorKey.currentState!.context;

  ScaffoldMessenger.of(currentContext).hideCurrentSnackBar();
}

showSnackBar(String text, {Color textColor = Colors.black}) {
  var currentContext = navigatorKey.currentState!.context;

  ScaffoldMessenger.of(currentContext).hideCurrentSnackBar();
  ScaffoldMessenger.of(currentContext).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.only(left: 10, right: 10),
      content: Container(
        height: 40,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(currentContext).scaffoldBackgroundColor,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

showInviteSnackBar(
  GameModel game, {
  int milliseconds = 10000,
  bool reset = false,
}) {
  try {
    var currentContext = navigatorKey.currentState!.context;

    ScaffoldMessenger.of(currentContext).hideCurrentSnackBar();
    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.purple.shade200.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(15, 5, 15, 60),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: milliseconds),
        padding: const EdgeInsets.only(left: 10, right: 10),
        content: InviteSnackBarLayout(
          game,
          milliseconds: milliseconds,
          reset: reset,
        ),
      ),
    );
  } catch (error) {
    print('Theres no Global Scoffold... $error');
  }
}
