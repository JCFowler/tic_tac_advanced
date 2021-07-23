import 'package:flutter/material.dart';

class RadiantGradientMask extends StatelessWidget {
  final Widget child;
  final List<Color> colors;

  const RadiantGradientMask({
    required this.child,
    required this.colors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.topLeft,
        radius: 0.5,
        colors: colors,
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}
