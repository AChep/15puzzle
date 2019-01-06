import 'dart:io';

import 'package:fifteenpuzzle/data/result.dart';
import 'package:fifteenpuzzle/widgets/game/cupertino/page.dart';
import 'package:fifteenpuzzle/widgets/game/material/page.dart';
import 'package:fifteenpuzzle/widgets/game/material/victory.dart';
import 'package:fifteenpuzzle/widgets/game/presenter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GamePage extends StatelessWidget {
  static const playGames = const MethodChannel(
      'com.artemchep.flutter/google_play_games');

  static const leaderboard3x3Id = 'CgkI25T8-IoFEAIQAg';
  static const leaderboard4x4Id = 'CgkI25T8-IoFEAIQAQ';
  static const leaderboard5x5Id = 'CgkI25T8-IoFEAIQAw';

  @override
  Widget build(BuildContext context) {
    final rootWidget = _buildRoot(context);
    return GamePresenterWidget(
      child: rootWidget,
      onSolve: (result) {
        _submitResult(result);
        _showVictoryDialog(context, result);
      },
    );
  }

  Widget _buildRoot(BuildContext context) {
    if (Platform.isIOS) {
      return GameCupertinoPage();
    } else {
      // Every other OS is based on a material
      // design application.
      return GameMaterialPage();
    }
  }

  void _showVictoryDialog(BuildContext context, Result result) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => Text(''),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => GameVictoryDialog(result: result),
      );
    }
  }

  void _submitResult(Result result) async {
    try {
      String id;
      if (result.size == 3) {
        id = leaderboard3x3Id;
      } else if (result.size == 4) {
        id = leaderboard4x4Id;
      } else if (result.size == 5) {
        id = leaderboard5x5Id;
      }

      // Submit the score to the
      // Google Play Games
      await playGames.invokeMethod(
          'submitScore', <String, dynamic>{
        'id': id,
        'score': result.time,
      });
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: 'Sending score failed $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
  }
}
