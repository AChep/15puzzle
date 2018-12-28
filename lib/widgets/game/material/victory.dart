import 'package:fifteenpuzzle/data/result.dart';
import 'package:flutter/material.dart';

class GameVictoryDialog extends StatelessWidget {
  final Result result;

  GameVictoryDialog({@required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Congratulations!",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("You've successfuly completed the puzzle"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    _formatElapsedTime(result.time),
                    style: Theme.of(context).textTheme.display1.copyWith(
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
                    style: Theme.of(context).textTheme.display1.copyWith(
                          color: Theme.of(context).textTheme.body1.color,
                        ),
                  ),
                ],
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

  String _formatElapsedTime(int millis) {
    final seconds = millis ~/ 1000;
    final fraction = millis % 1000 ~/ 100;

    final s = seconds ~/ 60;
    final m = seconds % 60;
    return '$s:${m <= 9 ? '0$m' : '$m'}.$fraction';
  }
}
