import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the configuration of the
/// user interface.
class ConfigUiContainer extends StatefulWidget {
  final Widget child;

  ConfigUiContainer({@required this.child});

  static _ConfigUiContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _ConfigUiContainerState createState() => _ConfigUiContainerState();
}

class _ConfigUiContainerState extends State<ConfigUiContainer> {
  static const _DEFAULT_USE_DARK_THEME = true;
  static const _KEY_USE_DARK_THEME = 'ui::dark_theme_enabled';

  /// `true` if the app uses a global dark theme,
  /// `false` otherwise.
  bool useDarkTheme;

  @override
  void initState() {
    super.initState();
    useDarkTheme = _DEFAULT_USE_DARK_THEME;

    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _loadThemePreferences(prefs);
  }

  void _loadThemePreferences(final SharedPreferences prefs) {
    final useDarkTheme =
        prefs.getBool(_KEY_USE_DARK_THEME) ?? this.useDarkTheme;
    setUseDarkTheme(useDarkTheme);
  }

  /// Sets if user want app to show up in a dark theme or
  /// a white theme.
  void setUseDarkTheme(final bool useDarkTheme,
      {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(_KEY_USE_DARK_THEME, useDarkTheme);
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
}

class _InheritedStateContainer extends InheritedWidget {
  final _ConfigUiContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
