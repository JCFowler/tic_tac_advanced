import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child;

  const BackgroundGradient({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.5),
              Colors.red.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
      ),
      child
    ]);
  }
}
