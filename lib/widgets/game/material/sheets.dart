import 'dart:io';
import 'dart:math';

import 'package:fifteenpuzzle/config/ui.dart';
import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/utils/platform.dart';
import 'package:fifteenpuzzle/widgets/about/dialog.dart';
import 'package:fifteenpuzzle/widgets/donate/dialog.dart';
import 'package:fifteenpuzzle/widgets/game/board.dart';
import 'package:fifteenpuzzle/widgets/game/material/page.dart';
import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter/widgets.dart';

Widget createMoreBottomSheet(
  BuildContext context, {
  @required Function(int) call,
}) {
  final config = ConfigUiContainer.of(context);

  Widget createBoard({int size}) => Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.black12,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Semantics(
                label: '${size}x$size',
                child: InkWell(
                  onTap: () {
                    call(size);
                    Navigator.of(context).pop();
                  },
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final puzzleSize = min(
                        min(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        96.0,
                      );

                      return Semantics(
                        excludeSemantics: true,
                        child: BoardWidget(
                          board: Board.createNormal(size),
                          onTap: null,
                          showNumbers: false,
                          size: puzzleSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Semantics(
              excludeSemantics: true,
              child: Align(
                alignment: Alignment.center,
                child: Text('${size}x$size'),
              ),
            ),
          ],
        ),
      );

  final items = <Widget>[
    SizedBox(height: 16),
    Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 4),
        IconButton(
          icon: const Icon(
            Icons.info_outline,
            semanticLabel: "Info",
          ),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return AboutDialog();
                });
          },
        ),
        if (platformCheck(() => Platform.isAndroid || Platform.isIOS))
          IconButton(
            icon: const Icon(
              Icons.credit_card,
              semanticLabel: "Donations",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (context) {
                    return DonateDialog();
                  });
            },
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlineButton(
              shape: const RoundedRectangleBorder(
                borderRadius:
                    const BorderRadius.all(const Radius.circular(16.0)),
              ),
              onPressed: () {
                // Cycle themes like this:
                // Auto -> Dark -> Light -> Auto ...
                bool shouldUseDarkTheme;
                if (config.useDarkTheme == null) {
                  shouldUseDarkTheme = true;
                } else if (config.useDarkTheme == true) {
                  shouldUseDarkTheme = false;
                } else {
                  shouldUseDarkTheme = null;
                }
                config.setUseDarkTheme(shouldUseDarkTheme, save: true);
              },
              child: Text(config.useDarkTheme == null
                  ? 'System theme'
                  : config.useDarkTheme == true
                      ? 'Dark theme'
                      : 'Light theme'),
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    ),
    SizedBox(height: 4),
    Row(
      children: <Widget>[
        SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: createBoard(size: 3),
          ),
        ),
        Expanded(child: createBoard(size: 4)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: createBoard(size: 5),
          ),
        ),
        SizedBox(width: 8),
      ],
    ),
    SizedBox(height: 16),
    CheckboxListTile(
      dense: true,
      title: const Text('Speed run mode'),
      secondary: const Icon(Icons.timer),
      subtitle: const Text('Reduce animations and switch controls to taps'),
      value: config.isSpeedRunModeEnabled,
      onChanged: (bool value) {
        var shouldEnableSpeedRun = !config.isSpeedRunModeEnabled;
        config.setSpeedRunModeEnabled(shouldEnableSpeedRun, save: true);
      },
    ),
  ];

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = min(
          constraints.maxWidth,
          GameMaterialPage.kMaxBoardSize,
        );

        return Column(
          children: [
            Container(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
          ],
        );
      },
    ),
  );
}
