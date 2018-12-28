import 'dart:math';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/data/result.dart';
import 'package:fifteenpuzzle/domain/game.dart';
import 'package:fifteenpuzzle/utils/serializable.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePresenterWidget extends StatefulWidget {
  static const SUPPORTED_SIZES = [3, 4, 5];

  final Widget child;

  final Function(Result) onSolve;

  GamePresenterWidget({@required this.child, this.onSolve});

  static GamePresenterWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  GamePresenterWidgetState createState() => GamePresenterWidgetState();
}

class GamePresenterWidgetState extends State<GamePresenterWidget>
    with WidgetsBindingObserver {
  static const TIME_STOPPED = 0;

  final Game game = Game.instance;

  Board board;

  int steps;

  int time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = null;
    steps = null;
    time = TIME_STOPPED;

    _loadState();
  }

  void _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final deserializer = SharedPrefSerializeInput(
      key: "state",
      prefs: prefs,
    );

    const boardFactory = BoardDeserializableFactory();
    var time = deserializer.readInt();
    var steps = deserializer.readInt();
    var board = deserializer.readDeserializable(boardFactory);

    final now = DateTime.now().millisecondsSinceEpoch;
    if ( // validate time
        time == null ||
            time < 0 ||
            time > now ||
            // validate steps
            steps == null ||
            steps < 0 ||
            // validate board
            board == null) {
      time = TIME_STOPPED;
      steps = 0;
      // Initialize empty board with a classic
      // pattern.
      const size = 4;
      board = _createBoard(size);
    }

    setState(() {
      this.time = time;
      this.steps = steps;
      this.board = board;
    });
  }

  Board _createBoard(int size) =>
      Board.create(size, (n) => Point(n % size, n ~/ size));

  void playStop() {
    if (isPlaying()) {
      stop();
    } else {
      play();
    }
  }

  void play() {
    assert(board != null);

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      time = now;
      steps = 0;
      board = game.shuffle(board);
    });
  }

  void stop() {
    setState(() {
      time = TIME_STOPPED;
      steps = 0;
    });
  }

  bool isPlaying() => time != TIME_STOPPED;

  void resize(int size) {
    setState(() {
      time = TIME_STOPPED;
      steps = 0;
      board = _createBoard(size);
    });
  }

  void tap({@required Point<int> point}) {
    assert(board != null);
    assert(point != null);

    setState(() {
      board = game.tap(board, point: point);

      if (isPlaying()) {
        // Increment the amount of steps.
        steps = steps + 1;

        // Stop if a user has solved the
        // board.
        if (board.isSolved()) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final result = Result(
            steps: steps,
            time: now - time,
          );

          widget.onSolve?.call(result);

          stop();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        _saveState();
        break;
      default:
        break;
    }
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final serializer = SharedPrefSerializeOutput(
      key: "state",
      prefs: prefs,
    );

    serializer.writeInt(time);
    serializer.writeInt(steps);
    serializer.writeSerializable(board);
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final GamePresenterWidgetState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
