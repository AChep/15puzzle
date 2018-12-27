import 'package:flutter/widgets.dart';

class GameRunnerWidget extends StatefulWidget {
  final Widget child;

  GameRunnerWidget({@required this.child});

  @override
  _GameRunnerWidgetState createState() => _GameRunnerWidgetState();
}

class _GameRunnerWidgetState extends State<GameRunnerWidget> {

  bool isPlaying;

  @override
  void initState() {
    super.initState();
    isPlaying = false;
  }

  void playStop() {

  }

  void stop() {
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
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
