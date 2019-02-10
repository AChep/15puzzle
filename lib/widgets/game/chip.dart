import 'package:fifteenpuzzle/data/chip.dart';
import 'package:flutter/material.dart' hide Chip;

class ChipWidget extends StatelessWidget {
  final Chip chip;

  final Function onPressed;

  final Color overlayColor;

  final Color backgroundColor;

  final double fontSize;

  final double size;

  final bool showNumber;

  ChipWidget(
    this.chip,
    this.overlayColor,
    this.backgroundColor,
    this.fontSize, {
    @required this.onPressed,
    @required this.size,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = size < 150;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(isCompact ? 4.0 : 8.0)),
    );

    var color = Theme.of(context).scaffoldBackgroundColor;
    color = Color.alphaBlend(backgroundColor, color);
    color = Color.alphaBlend(overlayColor, color);

    return Padding(
      padding: EdgeInsets.all(isCompact ? 2.0 : 4.0),
      child: Material(
        shape: shape,
        color: color,
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: showNumber
              ? Center(
                  child: Text(
                    '${chip.number + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
