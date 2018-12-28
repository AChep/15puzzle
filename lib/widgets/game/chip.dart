import 'package:fifteenpuzzle/data/chip.dart';
import 'package:flutter/material.dart' hide Chip;

class ChipWidget extends StatelessWidget {
  final Chip chip;

  final Function onPressed;

  final Color overlayColor;

  final Color backgroundColor;

  final double fontSize;

  ChipWidget(
    this.chip,
    this.overlayColor,
      this.backgroundColor,
      this.fontSize, {
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shape = const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
    );

    var color = Theme.of(context).scaffoldBackgroundColor;
    color = Color.alphaBlend(backgroundColor, color);
    color = Color.alphaBlend(overlayColor, color);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child:  Material(
        shape: shape,
        color: color,
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Center(
            child: Text(
              '${chip.number + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
