import 'package:fifteenpuzzle/utils/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget that can start / stop
/// a game.
class GamePlayStopButton extends StatefulWidget {
  final GamePresenter presenter;

  GamePlayStopButton(this.presenter);

  @override
  _GamePlayStopButtonState createState() => _GamePlayStopButtonState();
}

class _GamePlayStopButtonState extends AutoDisposableState<GamePlayStopButton> {
  @override
  void initState() {
    listenTo(widget.presenter.isPlaying.stream);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.presenter.isPlaying.value;
    return FloatingActionButton(
      onPressed: () {
        widget.presenter.playStop();
      },
      child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
    );
  }
}

/// Widget shows the current time of
/// a game.
class GameStopwatchWidget extends StatefulWidget {
  final GamePresenter presenter;

  final double fontSize;

  GameStopwatchWidget(this.presenter, {@required this.fontSize});

  @override
  _GameStopwatchWidgetState createState() => _GameStopwatchWidgetState();
}

class _GameStopwatchWidgetState extends AutoDisposableState<GameStopwatchWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

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

    listenTo(widget.presenter.elapsedTime.stream);
    autoDispose(widget.presenter.isPlaying.listen((isPlaying) {
      if (isPlaying) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.presenter.elapsedTime.value;
    final timeFormatted = _formatElapsedTime(time * 100);
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
        timeFormatted,
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
    super.dispose();
  }
}

/// Widget shows the current steps counter of
/// a game.
class GameStepsWidget extends StatefulWidget {
  final GamePresenter presenter;

  GameStepsWidget(this.presenter);

  @override
  _GameStepsState createState() => _GameStepsState();
}

class _GameStepsState extends AutoDisposableState<GameStepsWidget> {
  @override
  void initState() {
    listenTo(widget.presenter.stepsCounter.stream);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.presenter.stepsCounter.value;
    return Text(
      '$steps steps',
      style: Theme.of(context).textTheme.subtitle,
    );
  }
}
