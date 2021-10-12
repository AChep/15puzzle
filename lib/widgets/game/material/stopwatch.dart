import 'dart:async';

import 'package:fifteenpuzzle/widgets/auto_size_text.dart';
import 'package:fifteenpuzzle/widgets/game/format.dart';
import 'package:fifteenpuzzle/widgets/icons/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget shows the current time of
/// a game.
class GameStopwatchWidget extends StatefulWidget {
  final int time;

  final String Function(int) timeFormatter;

  final double fontSize;

  GameStopwatchWidget({
    @required this.time,
    @required this.fontSize,
    this.timeFormatter: formatElapsedTime,
  });

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
    final time = widget.time != 0
        ? DateTime.now().millisecondsSinceEpoch - widget.time
        : 0;
    final timeStr = widget.timeFormatter(time);
    final timeStrAtStartOfMinute = widget.timeFormatter(time - time % (1000 * 60));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          alignment: Alignment(0.0, 0.75),
          scale: 0.8 + 0.2 * animation.value,
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 220.0,
            height: 108.0,
            child: AutoSizeText(
              timeStrAtStartOfMinute,
              timeStr,
              maxLines: 1,
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontSize: widget.fontSize,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
            ),
          ),
          const SizedBox(width: 16.0),
          StopwatchIcon(
            size: 24,
            millis: time,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
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
