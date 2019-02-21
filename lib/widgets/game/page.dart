import 'package:fifteenpuzzle/data/result.dart';
import 'package:fifteenpuzzle/play_games.dart';
import 'package:fifteenpuzzle/widgets/game/material/page.dart';
import 'package:fifteenpuzzle/widgets/game/material/victory.dart';
import 'package:fifteenpuzzle/widgets/game/presenter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootWidget = _buildRoot(context);
    return GamePresenterWidget(
      child: rootWidget,
      onSolve: (result) {
        _submitResult(context, result);
        _showVictoryDialog(context, result);
      },
    );
  }

  Widget _buildRoot(BuildContext context) {
    return GameMaterialPage();
  }

  void _showVictoryDialog(BuildContext context, Result result) {
    showDialog(
      context: context,
      builder: (context) => GameVictoryDialog(result: result),
    );
  }

  void _submitResult(BuildContext context, Result result) {
    final playGames = PlayGamesContainer.of(context);
    playGames.submitScore(
      key: PlayGames.getLeaderboardOfSize(result.size),
      time: result.time,
    );
  }
}
