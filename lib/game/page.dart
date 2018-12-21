import 'dart:math';

import 'package:fifteenpuzzle/game/sheets.dart';
import 'package:fifteenpuzzle/game/widgets_board.dart';
import 'package:fifteenpuzzle/main.dart';
import 'package:fifteenpuzzle/widgets/icons/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'widgets.dart';

class GamePage extends StatelessWidget {
  GamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final presenter = AppStateContainer.of(context).game;

    final fabWidget = _buildFab(context);
    final boardWidget = _buildBoard(context);
    return OrientationBuilder(builder: (context, orientation) {
      final statusWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GameStopwatchWidget(presenter),
              const SizedBox(width: 16.0),
              Icon(
                Icons.access_time,
              ),
            ],
          ),
          GameStepsWidget(presenter),
        ],
      );

      if (orientation == Orientation.portrait) {
        //
        // Portrait layout
        //
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 56,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const AppIcon(size: 24.0),
                        const SizedBox(width: 16.0),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.title,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: statusWidget,
                  ),
                ),
                boardWidget,
                const SizedBox(height: 116.0),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: fabWidget,
        );
      } else {
        //
        // Landscape layout
        //
        return Scaffold(
          body: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                boardWidget,
                statusWidget,
              ],
            ),
          ),
          floatingActionButton: fabWidget,
        );
      }
    });
  }

  Widget _buildBoard(final BuildContext context) {
    final presenter = AppStateContainer.of(context).game;
    final background = Theme.of(context).brightness == Brightness.dark
        ? Colors.black54
        : Colors.black12;
    return Center(
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final puzzleSize = min(constraints.maxWidth, constraints.maxHeight);
            return BoardWidget(
              game: presenter.game,
              size: puzzleSize,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab(final BuildContext context) {
    final presenter = AppStateContainer.of(context).game;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: 64.0),
        GamePlayStopButton(presenter),
        const SizedBox(width: 16.0),
        Container(
          width: 48,
          height: 48,
          child: Material(
            elevation: 0.0,
            color: Colors.transparent,
            shape: CircleBorder(),
            child: InkWell(
              onTap: () {
                // Show the modal bottom sheet on
                // tap on "More" icon.
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return createMoreBottomSheet(context);
                  },
                );
              },
              customBorder: CircleBorder(),
              child: Icon(Icons.more_vert),
            ),
          ),
        ),
      ],
    );
  }
}
