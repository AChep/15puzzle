import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget shows the current steps counter of
/// a game.
class GameStepsWidget extends StatefulWidget {
  final int steps;

  GameStepsWidget({@required this.steps});

  @override
  _GameStepsState createState() => _GameStepsState();
}

class _GameStepsState extends State<GameStepsWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.steps} steps',
      style: Theme.of(context).textTheme.subtitle1,
    );
  }
}
