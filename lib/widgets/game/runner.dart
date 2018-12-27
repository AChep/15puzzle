import 'dart:math';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/domain/game.dart';
import 'package:fifteenpuzzle/utils/serializable.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameRunnerWidget extends StatefulWidget {
  final Widget child;

  GameRunnerWidget({@required this.child});

  static _GameRunnerWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _GameRunnerWidgetState createState() => _GameRunnerWidgetState();
}

class _GameRunnerWidgetState extends State<GameRunnerWidget>
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
    if (time == null || time < 0 || time > now) {
      time = TIME_STOPPED;
    }

    if (steps == null || steps < 0) {
      steps = 0;
    }

    if (board == null) {
      // Initialize empty board with a classic
      // pattern.
      const size = 4;
      board = Board.create(size, (n) => Point(n % size, n ~/ size));
    }

    setState(() {
      this.time = time;
      this.steps = steps;
      this.board = board;
    });
  }

  void play() {
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

  void isPlaying() => time != TIME_STOPPED;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveState();
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
  final _GameRunnerWidgetState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
