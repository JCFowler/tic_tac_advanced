import 'package:flutter/material.dart';

class SpinningIcon extends StatefulWidget {
  final Icon icon;

  const SpinningIcon({
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    duration: const Duration(milliseconds: 3600),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.icon,
    );
  }
}
