import 'package:fifteenpuzzle/data/board.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the configuration of the
/// game.
class ConfigGameContainer extends StatefulWidget {
  final Widget child;

  ConfigGameContainer({@required this.child});

  static _ConfigGameContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _ConfigGameContainerState createState() => _ConfigGameContainerState();
}

class _ConfigGameContainerState extends State<ConfigGameContainer> {
  static const _KEY_BOARD = 'game::board::';

  /// **Nullable**
  Board board;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _loadBoardSizePreferences(prefs);
  }

  void _loadBoardSizePreferences(final SharedPreferences prefs) {
    final useDarkTheme =
        prefs.getBool(_KEY_BOARD_SIZE) ?? _DEFAULT_BOARD_SIZE;
    setBoardSize(useDarkTheme);
  }

  void setBoard(final Board board, {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_KEY_BOARD_SIZE, boardSize);
    }

    setState(() {
      this.boardSize = boardSize;
    });
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
  final _ConfigGameContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) =>
      data.boardSize != old.data.boardSize;
}
