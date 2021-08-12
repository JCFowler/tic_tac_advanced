import 'dart:async';

import 'package:flutter/material.dart';

const tickerAmount = 10;

class LoadingBar extends StatefulWidget {
  final int milliseconds;
  final bool hideSnackBar;
  final bool reset;

  const LoadingBar(
    this.milliseconds, {
    this.hideSnackBar = false,
    this.reset = false,
    Key? key,
  }) : super(key: key);

  @override
  _LoadingBarState createState() => _LoadingBarState();
}

Timer? timer;
double percentage = 0.0;
int ticks = 0;

class _LoadingBarState extends State<LoadingBar> {
  @override
  void initState() {
    if (widget.reset) {
      percentage = 0.0;
      ticks = 0;
    }

    timer =
        Timer.periodic(const Duration(milliseconds: tickerAmount), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        ticks++;
      });
      if ((ticks * tickerAmount) >= widget.milliseconds) {
        if (widget.hideSnackBar) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        t.cancel();
        percentage = 0.0;
        ticks = 0;
      }
      setState(() {
        percentage = (ticks * tickerAmount) / widget.milliseconds;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: widget.milliseconds),
      child: LinearProgressIndicator(
        value: percentage,
        color: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
