import 'package:flutter/material.dart';

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
