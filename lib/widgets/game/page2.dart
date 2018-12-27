import 'dart:io';

import 'package:fifteenpuzzle/config/game.dart';
import 'package:fifteenpuzzle/widgets/game/board.dart';
import 'package:flutter/widgets.dart';

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootWidget = _buildRoot(context);
    return ConfigGameContainer(
      child: rootWidget,
    );
  }

  Widget _buildRoot(BuildContext context) {
    final BoardWidget boardWidget = null;
    if (Platform.isIOS) {
      return _GameCupertinoPage(boardWidget: boardWidget);
    } else {
      // Every other OS is based on a material
      // design application.
      return _GameMaterialPage(boardWidget: boardWidget);
    }
  }
}

class _GameMaterialPage extends StatelessWidget {
  final BoardWidget boardWidget;

  _GameMaterialPage({@required this.boardWidget});

  @override
  Widget build(BuildContext context) {
    return null;
  }
}

class _GameCupertinoPage extends StatelessWidget {
  final BoardWidget boardWidget;

  _GameCupertinoPage({@required this.boardWidget});

  @override
  Widget build(BuildContext context) {
    return null;
  }
}
