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
            onTap: () {
              launchUrl(url: URL_AUTHOR);
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text("Repository"),
          onPressed: () {
            launchUrl(url: URL_REPOSITORY);
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
}
