import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'loading_bar.dart';

class InviteSnackBarLayout extends StatelessWidget {
  final Invited invited;
  final int? milliseconds;

  const InviteSnackBarLayout(
    this.invited, {
    this.milliseconds,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person),
                FittedBox(
                  child: Text(
                    '${invited.inviteeUsername} Invited you.',
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
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
          if (milliseconds != null)
            LoadingBar(milliseconds!, hideSnackBar: true),
        ],
      ),
    );
  }
}
