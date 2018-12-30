import 'package:fifteenpuzzle/config/ui.dart';
import 'package:fifteenpuzzle/game/dialogs.dart';
import 'package:fifteenpuzzle/widgets/game/presenter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget createMoreBottomSheet(
  BuildContext context, {
  @required int psize,
  @required Function(int) call,
}) {
  final config = ConfigUiContainer.of(context);
//  final state = GameRunnerWidget.of(context);

  Widget createSeparator(String text) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.caption,
        ),
      );

  final items = <Widget>[
    ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About'),
      onTap: () {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return createAboutDialog(context);
            });
      },
    ),
//    ListTile(
//      leading: const Icon(Icons.people_outline),
//      title: const Text('Contribute'),
//      onTap: () {},
//    ),
    const Divider(),
  ];

  // Add board settings
  items.add(createSeparator('Board size'));
  items.addAll(GamePresenterWidget.SUPPORTED_SIZES.map((size) {
    return RadioListTile(
      value: size,
      groupValue: psize,
      title: Text('${size}x$size'),
      dense: true,
      onChanged: (_) {
        call(size);
        Navigator.of(context).pop();
      },
    );
  }));

  // Add theme settings
  items.add(createSeparator('Theme'));
  items.add(SwitchListTile(
    value: config.useDarkTheme,
    title: Text('Dark theme'),
    onChanged: (useDarkTheme) {
      config.setUseDarkTheme(useDarkTheme, save: true);
      Navigator.of(context).pop();
    },
  ));

  return new Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items,
  );
}
