import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitingText extends StatefulWidget {
  final String text;
  const WaitingText(
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  State<WaitingText> createState() => _WaitingTextState();
}

class _WaitingTextState extends State<WaitingText>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  AnimationController? _controller2;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RotationTransition(
          turns: const AlwaysStoppedAnimation(180 / 360),
          child: SpinKitThreeBounce(
            color: Colors.purple.shade300,
            size: 15,
            controller: _controller,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: 20,
            ),
          ),
        ),
        SpinKitThreeBounce(
          color: Colors.purple.shade300,
          size: 15,
          controller: _controller2,
        ),
      ],
    );
  }
}
