import 'dart:io';

import 'package:fifteenpuzzle/config/ui.dart';
import 'package:fifteenpuzzle/widgets/game/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(
      ConfigUiContainer(
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Game of Fifteen';
    if (Platform.isIOS) {
      return _MyCupertinoApp(title: title);
    } else {
      // Every other OS is based on a material
      // design application.
      return _MyMaterialApp(title: title);
    }
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
    final theme = ui.useDarkTheme ? ThemeData.dark() : ThemeData.light();

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
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
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
