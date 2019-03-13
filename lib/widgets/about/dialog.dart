import 'package:fifteenpuzzle/links.dart';
import 'package:fifteenpuzzle/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('About'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Game of Fifteen is a free and open source app '
              'written with Flutter. It features beautiful design and '
              'smooth animations.'),
          const SizedBox(height: 8),
          const Text('You can compete with your friends online. '
              'The complexity of puzzles is similar from game to game.'),
          const SizedBox(height: 24),
          Text(
            'Developed by',
            style: Theme.of(context).textTheme.subtitle,
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
            onTap: () {
              launchUrl(url: URL_AUTHOR);
            },
          ),
          ListTile(
            leading: Icon(Icons.code, size: 32),
            title: const Text('Join development'),
            onTap: () {
              launchUrl(url: URL_REPOSITORY);
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
