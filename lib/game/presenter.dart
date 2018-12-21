import 'dart:async';
import 'dart:math';

import 'package:fifteenpuzzle/game/logic/board.dart';
import 'package:fifteenpuzzle/game/logic/game.dart';
import 'package:fifteenpuzzle/result.dart';
import 'package:rxdart/subjects.dart';

class GamePresenter {
  static const SUPPORTED_SIZES = [3, 4, 5];

  Game game;

  /// Live event of a 'Whoa, you have won!'.
  var solveResultEvent = PublishSubject<Result>();

  /// Live event of a 'Whoa, you have set another size of
  /// a dimension of a puzzle'.
  var resizeEvent = PublishSubject<int>();

  var isPlaying = BehaviorSubject<bool>(seedValue: false);

  var elapsedTime = BehaviorSubject<int>(seedValue: 0);

  var stepsCounter = BehaviorSubject<int>(seedValue: 0);

  Timer _timer;

  GamePresenter() {
    //final board = _createBoard(size);
    game = Game(
      onTap: _step,
      onSolve: () {
        final result = Result(
          steps: stepsCounter.value,
          time: elapsedTime.value,
        );

        final hasStopped = stop();
        if (hasStopped) {
          solveResultEvent.add(result);
        }
      },
    );

    // Setup observers
    isPlaying.stream.listen((isPlaying) {
      if (isPlaying) {
        game.shuffle();

        // Reset the game params and start the
        // stopwatch.
        _resetCounters();
        _timer = Timer.periodic(
          const Duration(milliseconds: 100),
          (timer) {
            elapsedTime.value = _timer.tick;
          },
        );
      } else {
        _resetCounters();
        _disposeTimer();
      }
    });
  }

  void _step() {
    // Increment the steps counter only
    // if user is currently playing.
    if (isPlaying.value) {
      stepsCounter.value += 1;
    }
  }

  Board _createBoard(int size) =>
      Board.create(size, (n) => Point(n % size, n ~/ size));

  void playStop() {
    final wasPlaying = isPlaying.value;
    isPlaying.value = !wasPlaying;
  }

  /// Stops the if [isPlaying.value] is `true`, otherwise
  /// does nothing.
  ///
  /// Returns `true` if it has stopped the game.
  bool stop() {
    if (isPlaying.value) {
      isPlaying.value = false;
      return true;
    }

    return false;
  }

  void resize(int size) {
    stop();

    game.board.value = _createBoard(size);
    resizeEvent.add(size);
  }

  void dispose() {
    _disposeTimer();
    game.dispose();

    solveResultEvent.close();
    resizeEvent.close();

    isPlaying.close();
    elapsedTime.close();
    stepsCounter.close();
  }

  void _resetCounters() {
    stepsCounter.value = 0;
    elapsedTime.value = 0;
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
