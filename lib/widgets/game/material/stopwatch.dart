import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget shows the current time of
/// a game.
class GameStopwatchWidget extends StatefulWidget {
  final int time;

  final double fontSize;

  GameStopwatchWidget({@required this.time, @required this.fontSize});

  @override
  _GameStopwatchWidgetState createState() => _GameStopwatchWidgetState();
}

class _GameStopwatchWidgetState extends State<GameStopwatchWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  Timer timer;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    );

    super.initState();

    final isPlaying = widget.time != 0;
    _performSetIsPlaying(isPlaying);
  }

  @override
  void didUpdateWidget(GameStopwatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPlaying = oldWidget.time != 0;
    final isPlaying = widget.time != 0;

    if (isPlaying != wasPlaying) {
      _performSetIsPlaying(isPlaying);
    }
  }

  void _performSetIsPlaying(final bool isPlaying) {
      // Play scale animation when the state of the
      // game changes.
      if (isPlaying) {
        controller.forward();
      } else {
        controller.reverse();
      }

      // Control the timer.
      _disposeTimer();

      if (isPlaying) {
        timer = Timer.periodic(
          const Duration(milliseconds: 100),
              (timer) => setState(() {}), // rebuild the widget
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatElapsedTime(widget.time != 0
        ? DateTime.now().millisecondsSinceEpoch - widget.time
        : 0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          alignment: Alignment(0.0, 0.75),
          scale: 0.8 + 0.2 * animation.value,
          child: child,
        );
      },
      child: Text(
        timeStr,
        style: Theme.of(context).textTheme.display3.copyWith(
              fontSize: widget.fontSize,
              color: Theme.of(context).textTheme.title.color,
            ),
      ),
    );
  }

  String _formatElapsedTime(int millis) {
    final seconds = millis ~/ 1000;
    final fraction = millis % 1000 ~/ 100;

    final s = seconds ~/ 60;
    final m = seconds % 60;
    return '$s:${m <= 9 ? '0$m' : '$m'}.$fraction';
  }

  @override
  void dispose() {
    controller.dispose();
    _disposeTimer();
    super.dispose();
  }

  void _disposeTimer() {
    timer?.cancel();
    timer = null;
  }
}
