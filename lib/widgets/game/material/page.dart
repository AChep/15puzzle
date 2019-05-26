import 'dart:math';

import 'package:fifteenpuzzle/widgets/game/board.dart';
import 'package:fifteenpuzzle/widgets/game/material/control.dart';
import 'package:fifteenpuzzle/widgets/game/material/sheets.dart';
import 'package:fifteenpuzzle/widgets/game/material/steps.dart';
import 'package:fifteenpuzzle/widgets/game/material/stopwatch.dart';
import 'package:fifteenpuzzle/widgets/game/presenter/main.dart';
import 'package:fifteenpuzzle/widgets/icons/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameMaterialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presenter = GamePresenterWidget.of(context);

    final screenSize = MediaQuery.of(context).size;
    final screenWidth =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? screenSize.width
            : screenSize.height;
    final screenHeight =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? screenSize.height
            : screenSize.width;

    final isTallScreen = screenHeight / screenWidth > 1.9;
    final isLargeScreen = screenWidth > 400;

    final fabWidget = _buildFab(context);
    final boardWidget = _buildBoard(context);
    return OrientationBuilder(builder: (context, orientation) {
      final statusWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GameStopwatchWidget(
            time: presenter.time,
            fontSize: orientation == Orientation.landscape && !isLargeScreen
                ? 56.0
                : 72.0,
          ),
          GameStepsWidget(
            steps: presenter.steps,
          ),
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
                isTallScreen
                    ? Container(
                        height: 56,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const AppIcon(size: 24.0),
                              const SizedBox(width: 16.0),
                              Text(
                                'Game of Fifteen',
                                style: Theme.of(context).textTheme.title,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(height: 0),
                Expanded(
                  child: Center(
                    child: statusWidget,
                  ),
                ),
                boardWidget,
                isLargeScreen && isTallScreen
                    ? const SizedBox(height: 116.0)
                    : const SizedBox(height: 72.0),
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
    final presenter = GamePresenterWidget.of(context);
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
            final puzzleSize = min(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return BoardWidget(
              board: presenter.board,
              size: puzzleSize,
              onTap: (point) {
                presenter.tap(point: point);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab(final BuildContext context) {
    final presenter = GamePresenterWidget.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          child: Material(
            elevation: 0.0,
            color: Colors.transparent,
            shape: CircleBorder(),
            child: InkWell(
              onTap: () {
                presenter.reset();
              },
              customBorder: CircleBorder(),
              child: Icon(Icons.refresh),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        GamePlayStopButton(
          isPlaying: presenter.isPlaying(),
          onTap: () {
            presenter.playStop();
          },
        ),
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
                    return createMoreBottomSheet(context, call: (size) {
                      presenter.resize(size);
                    });
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
