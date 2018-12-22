import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {

  final double size;

  const AppIcon({this.size}) : super();

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? IconTheme.of(context).size;
    return Container(
      width: size,
      height: size,
      child: Material(
        shape: CircleBorder(),
        elevation: 4.0,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Text(
            '15',
            style: Theme.of(context).primaryTextTheme.title.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }
}
