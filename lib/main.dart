import 'package:fifteenpuzzle/config.dart';
import 'package:fifteenpuzzle/game/page.dart';
import 'package:fifteenpuzzle/game/presenter.dart';
import 'package:fifteenpuzzle/utils/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(
      AppStateContainer(
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateContainer.of(context);

    // Get current theme from
    // a global state.
    final overlay = state.useDarkTheme
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final theme = state.useDarkTheme ? ThemeData.dark() : ThemeData.light();

    SystemChrome.setSystemUIOverlayStyle(
      overlay.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      theme: theme.copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.amberAccent,
        dialogTheme: DialogTheme(
          shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
          ),
        ),
      ),
      home: GamePage(title: 'Game of Fifteen'),
    );
  }
}

class AppStateContainer extends StatefulWidget {
  final Widget child;

  AppStateContainer({@required this.child});

  // This creates a method on the AppState that's just like 'of'
  // On MediaQueries, Theme, etc
  // This is the secret to accessing your AppState all over your app
  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}

class _AppStateContainerState extends AutoDisposableState<AppStateContainer> {
  static const _DEFAULT_GAME_SIZE = 4;
  static const _DEFAULT_USE_DARK_THEME = true;

  GamePresenter game;

  /// `true` if the app uses a global dark theme,
  /// `false` otherwise.
  bool useDarkTheme;

  @override
  void initState() {
    super.initState();
    game = GamePresenter();
    game.resizeEvent.listen((final size) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(KEY_GAME_SIZE, size);
    });

    useDarkTheme = _DEFAULT_USE_DARK_THEME;

    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _loadGamePreferences(prefs);
    _loadThemePreferences(prefs);
  }

  void _loadGamePreferences(final SharedPreferences prefs) {
    game.resize(prefs.getInt(KEY_GAME_SIZE) ?? _DEFAULT_GAME_SIZE);
  }

  void _loadThemePreferences(final SharedPreferences prefs) {
    final useDarkTheme =
        prefs.getBool(KEY_UI_DARK_THEME_ENABLED) ?? this.useDarkTheme;
    setUseDarkTheme(useDarkTheme);
  }

  /// Sets if user want app to show up in a dark theme or
  /// a white theme.
  void setUseDarkTheme(final bool useDarkTheme, {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(KEY_UI_DARK_THEME_ENABLED, useDarkTheme);
    }

    setState(() {
      this.useDarkTheme = useDarkTheme;
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

  @override
  void dispose() {
    super.dispose();
    game.dispose();
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _AppStateContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
