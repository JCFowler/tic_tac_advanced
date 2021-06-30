import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
                    // transform: Matrix4.rotationZ(-15 * pi / 180)
                    //   ..translate(10.0),
                    child: Text(
                      'Tic Tac\nAdvanced',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text('Play'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(SettingsScreen.routeName),
                        child: Text('Settings'),
                      ),
                      Text(AppLocalizations.of(context)!.helloWorld)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
