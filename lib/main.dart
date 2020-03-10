import 'dart:io';

import 'package:fifteenpuzzle/config/ui.dart';
import 'package:fifteenpuzzle/play_games.dart';
import 'package:fifteenpuzzle/utils/platform.dart';
import 'package:fifteenpuzzle/widgets/game/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  _setTargetPlatformForDesktop();
  runApp(
    PlayGamesContainer(
      child: ConfigUiContainer(
        child: MyApp(),
      ),
    ),
  );
}

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (platformCheck(() => Platform.isMacOS)) {
    targetPlatform = TargetPlatform.iOS;
  } else if (platformCheck(() => Platform.isLinux || Platform.isWindows)) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Game of Fifteen';
    return _MyMaterialApp(title: title);
  }
}

/// Base class for all platforms, such as
/// [Platform.isIOS] or [Platform.isAndroid].
abstract class _MyPlatformApp extends StatelessWidget {
  final String title;

  _MyPlatformApp({@required this.title});
}

class _MyMaterialApp extends _MyPlatformApp {
  _MyMaterialApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);

    // Get current theme from
    // a global state.
    final overlay = ui.useDarkTheme
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final theme = ui.useDarkTheme
        ? ThemeData(
            brightness: Brightness.dark,
            canvasColor: Color(0xFF121212),
            backgroundColor: Color(0xFF121212),
            cardColor: Color(0xFF1E1E1E),
          )
        : ThemeData.light();

    SystemChrome.setSystemUIOverlayStyle(
      overlay.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: title,
      theme: theme.copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.amberAccent,
        accentIconTheme: theme.iconTheme.copyWith(color: Colors.black),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
        textTheme: theme.textTheme.apply(fontFamily: 'ManRope'),
        primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'ManRope'),
        accentTextTheme: theme.accentTextTheme.apply(fontFamily: 'ManRope'),
      ),
      home: GamePage(),
    );
  }
}

class _MyCupertinoApp extends _MyPlatformApp {
  _MyCupertinoApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: title,
    );
  }
}
