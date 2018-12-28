import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget that can start / stop
/// a game.
class GamePlayStopButton extends StatefulWidget {
  final bool isPlaying;

  final Function() onTap;

  GamePlayStopButton({
    @required this.isPlaying,
    this.onTap,
  });

  @override
  _GamePlayStopButtonState createState() => _GamePlayStopButtonState();
}

class _GamePlayStopButtonState extends State<GamePlayStopButton>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    animation.addListener(() => setState(() {}));

    super.initState();

    // Don't play the initial animation.
    final isPlaying = widget.isPlaying;
    controller.value = isPlaying ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(GamePlayStopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPlaying = oldWidget.isPlaying;
    final isPlaying = widget.isPlaying;
    if (isPlaying != wasPlaying) {
      _performSetIsPlaying(isPlaying);
    }
  }

  void _performSetIsPlaying(bool isPlaying) {
    if (isPlaying) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => widget.onTap?.call(),
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: _range(1.0 - animation.value, begin: 0.0, end: 1.0),
            child: Transform.rotate(
              angle: animation.value * pi / 2.0,
              child: Icon(Icons.play_arrow),
            ),
          ),
          Opacity(
            opacity: _range(animation.value, begin: 0.0, end: 1.0),
            child: Transform.rotate(
              angle: animation.value * pi / 2.0,
              child: Icon(Icons.stop),
            ),
          ),
        ],
      ),
    );
  }

  double _range(double v, {@required double begin, @required double end}) =>
      max(min(v, end), begin);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
