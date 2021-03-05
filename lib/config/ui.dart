import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the configuration of the
/// user interface.
class ConfigUiContainer extends StatefulWidget {
  final Widget child;

  ConfigUiContainer({@required this.child});

  static _ConfigUiContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        .data;
  }

  @override
  _ConfigUiContainerState createState() => _ConfigUiContainerState();
}

class _ConfigUiContainerState extends State<ConfigUiContainer> {
  static const _DEFAULT_USE_DARK_THEME = null;
  static const _DEFAULT_SPEED_RUN_MODE_ENABLED = false;
  static const _KEY_USE_DARK_THEME = 'ui::dark_theme_enabled';
  static const _KEY_SPEED_RUN_MODE_ENABLED = 'ui::speed_run_mode_enabled';

  /// `true` if the app uses a global dark theme,
  /// `false` otherwise.
  bool useDarkTheme;

  bool isSpeedRunModeEnabled;

  @override
  void initState() {
    super.initState();
    useDarkTheme = _DEFAULT_USE_DARK_THEME;
    isSpeedRunModeEnabled = _DEFAULT_SPEED_RUN_MODE_ENABLED;

    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on Exception {
      return;
    }
    _loadThemePreferences(prefs);
    _loadSpeedRunPreferences(prefs);
  }

  void _loadThemePreferences(final SharedPreferences prefs) {
    final useDarkTheme = prefs.getBool(_KEY_USE_DARK_THEME);
    setUseDarkTheme(useDarkTheme);
  }

  void _loadSpeedRunPreferences(final SharedPreferences prefs) {
    final isSpeedRunModeEnabled = prefs.getBool(_KEY_SPEED_RUN_MODE_ENABLED) ??
        this.isSpeedRunModeEnabled;
    setSpeedRunModeEnabled(isSpeedRunModeEnabled);
  }

  /// Sets if user want app to show up in a dark theme or
  /// a white theme.
  void setUseDarkTheme(final bool useDarkTheme,
      {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (useDarkTheme == null) {
          prefs.remove(_KEY_USE_DARK_THEME);
        } else {
          prefs.setBool(_KEY_USE_DARK_THEME, useDarkTheme);
        }
      } on Exception {}
    }

    setState(() {
      this.useDarkTheme = useDarkTheme;
    });
  }

  void setSpeedRunModeEnabled(final bool isEnabled,
      {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_KEY_SPEED_RUN_MODE_ENABLED, isEnabled);
      } on Exception {}
    }

    setState(() {
      this.isSpeedRunModeEnabled = isEnabled;
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
