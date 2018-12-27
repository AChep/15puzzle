import 'package:fifteenpuzzle/data/result.dart';
import 'package:flutter/material.dart';

AlertDialog createVictoryDialog(BuildContext context, Result result) {
  return AlertDialog(
    title: Center(
      child: Text(
        "You've won!",
        style: Theme.of(context).textTheme.display1,
      ),
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Time:',
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              '${result.time}',
              style: Theme.of(context).textTheme.display3.copyWith(
                    color: Theme.of(context).textTheme.body1.color,
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Steps:',
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              '${result.steps}',
              style: Theme.of(context).textTheme.display3.copyWith(
                    color: Theme.of(context).textTheme.body1.color,
                  ),
            ),
          ],
        ),
      ],
    ),
    actions: <Widget>[
      // usually buttons at the bottom of the dialog
      new FlatButton(
        child: new Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

AlertDialog createAboutDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('About'),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Game of Fifteen is a free and open source app '
            'written with Flutter.'),
        const SizedBox(height: 32),
        Text(
          'Developed by',
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: ClipOval(
            child: Image.network(
              'https://achep-84559.firebaseapp.com/static/avatar.jpg',
              width: 32,
              height: 32,
            ),
          ),
          title: const Text('Artem Chepurnoy'),
        ),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        child: new Text("Repository"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      new FlatButton(
        child: new Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
