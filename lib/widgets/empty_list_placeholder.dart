import 'package:flutter/material.dart';

import 'spinning_icon.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final String title;

  const EmptyListPlaceholder(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SpinningIcon(
          icon: Icon(
            Icons.sentiment_dissatisfied,
            size: 60,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
