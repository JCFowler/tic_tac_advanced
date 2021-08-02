import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../models/l10n.dart';
import '../providers/game_provider.dart';

final Paint _paint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 6
  ..color = Colors.purple.shade600;

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? child;

  const AppButton(
    this.text,
    this.onTap, {
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;

    final translatedText = translate(text, context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      height: _deviceSize.height * 0.12,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).dialogBackgroundColor,
          side: const BorderSide(
            width: 1.0,
            color: Colors.purple,
          ),
          elevation: 20,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: child ??
              FittedBox(
                child: Stack(
                  children: [
                    Text(
                      translatedText,
                      style: TextStyle(
                        fontSize: 40,
                        foreground: _paint,
                      ),
                    ),
                    Text(
                      translatedText,
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class NavigatorAppButton extends StatelessWidget {
  final String text;
  final String routeName;
  final GameType? gameType;

  const NavigatorAppButton(
    this.text, {
    Key? key,
    required this.routeName,
    this.gameType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text,
      () {
        if (gameType != null) {
          Provider.of<GameProvider>(context, listen: false)
              .setGameType(gameType!);
        }
        Navigator.of(context).pushNamed(routeName);
      },
    );
  }
}

class LoadingAppButton extends StatelessWidget {
  const LoadingAppButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      'loading',
      () {},
      child: CircularProgressIndicator(
        color: Theme.of(context).accentColor,
      ),
    );
  }
}
