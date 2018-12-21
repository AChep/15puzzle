import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutDialog extends AlertDialog {
  AboutDialog(BuildContext context)
      : super(
          title: Text('About'),
          content: ListView(
            children: <Widget>[
              Text('Game of Fifteen is a simple free open source app '
                  'written with Flutter.'),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
}
