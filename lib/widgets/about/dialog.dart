import 'package:fifteenpuzzle/links.dart';
import 'package:fifteenpuzzle/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 24);

    Padding HorizontalPadding(Widget child) {
      return Padding(
        padding: padding,
        child: child,
      );
    }

    return SimpleDialog(
      title: Text('About'),
      children: <Widget>[
        HorizontalPadding(
            const Text('Game of Fifteen is a free and open source app '
                'written with Flutter. It features beautiful design and '
                'smooth animations.')),
        const SizedBox(height: 8),
        HorizontalPadding(
            const Text('You can compete with your friends online. '
                'The complexity of puzzles is similar from game to game.')),
        const SizedBox(height: 24),
        ListTile(
          leading: Icon(Icons.code, size: 24),
          contentPadding: padding,
          title: const Text('Join development'),
          onTap: () {
            launchUrl(url: URL_REPOSITORY);
          },
        ),
        ListTile(
          leading: Icon(Icons.bug_report, size: 24),
          contentPadding: padding,
          title: const Text('Send bug report'),
          onTap: () {
            launchUrl(url: URL_FEEDBACK);
          },
        ),
      ],
    );
  }
}
