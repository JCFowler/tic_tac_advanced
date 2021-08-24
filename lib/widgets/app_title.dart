import 'package:flutter/material.dart';

final Paint paint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 6
  ..color = Colors.purple.shade600;

class AppTitle extends StatelessWidget {
  final String text;
  final bool regularSize;

  const AppTitle(
    this.text, {
    this.regularSize = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Column(
      children: [
        if (regularSize) SizedBox(height: deviceSize.height * 0.12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height: regularSize ? deviceSize.height * 0.15 : null,
            child: FittedBox(
              child: Stack(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 39,
                      foreground: paint,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.blue[50],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (regularSize) SizedBox(height: deviceSize.height * 0.05),
      ],
    );
  }
}
