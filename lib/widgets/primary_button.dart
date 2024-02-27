import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final double fontSize;

  /// Use expanded if there are more than 1 button in a row.
  final bool expanded;

  const PrimaryButton(
    this.text, {
    required this.onPressed,
    this.expanded = false,
    this.backgroundColor = Colors.purple,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(5),
    this.fontSize = 30,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Padding(
      padding: padding,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          minimumSize: const Size(
            double.infinity,
            45,
          ),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: button) : button;
  }
}
