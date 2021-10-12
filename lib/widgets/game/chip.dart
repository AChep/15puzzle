import 'package:flutter/material.dart' hide Chip;

class ChipWidget extends StatelessWidget {
  final String text;

  final Function onPressed;

  final Color overlayColor;

  final Color backgroundColor;

  final double fontSize;

  final double size;

  ChipWidget(
    this.text,
    this.overlayColor,
    this.backgroundColor,
    this.fontSize, {
    @required this.onPressed,
    @required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = size < 150;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(isCompact ? 4.0 : 8.0)),
    );

    var color = Theme.of(context).cardColor;
    color = Color.alphaBlend(backgroundColor, color);
    color = Color.alphaBlend(overlayColor, color);

    return Semantics(
      label: "",
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 2.0 : 4.0),
        child: Material(
          shape: shape,
          color: color,
          elevation: 1,
          child: InkWell(
            onTap: onPressed,
            customBorder: shape,
            child: text != null
                ? Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
