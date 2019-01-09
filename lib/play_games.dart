import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

const _LEADERBOARD_3x3 = 'CgkI25T8-IoFEAIQBQ';
const _LEADERBOARD_4x4 = 'CgkI25T8-IoFEAIQBg';
const _LEADERBOARD_5x5 = 'CgkI25T8-IoFEAIQBw';

class PlayGames {
  /// Returns the key to a leaderboard
  /// of a puzzle
  static String getLeaderboardOfSize(int size) {
    String id;
    if (size == 3) {
      id = _LEADERBOARD_3x3;
    } else if (size == 4) {
      id = _LEADERBOARD_4x4;
    } else if (size == 5) {
      id = _LEADERBOARD_5x5;
    }

    return id;
  }
}

class PlayGamesContainer extends StatefulWidget {
  final Widget child;

  PlayGamesContainer({@required this.child});

  static _PlayGamesContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _PlayGamesContainerState createState() => _PlayGamesContainerState();
}

class _PlayGamesContainerState extends State<PlayGamesContainer> {
  static const playGames =
      const MethodChannel('com.artemchep.flutter/google_play_games');

  @override
  void initState() {
    super.initState();
  }

  void submitScore({@required String key, @required int time}) async {
    try {
      await playGames.invokeMethod(
        'submitScore',
        <String, dynamic>{
          'id': key,
          'score': time,
        },
      );
    } on PlatformException {}
  }

  void showLeaderboard({@required String key}) async {
    try {
      await playGames.invokeMethod(
        "showLeaderboard",
        <String, dynamic>{
          'id': key,
        },
      );
    } on PlatformException {}
  }

  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of an app.
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _PlayGamesContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
