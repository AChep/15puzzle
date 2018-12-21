import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

abstract class AutoDisposableState<T extends StatefulWidget> extends State<T> {
  final _compositeSubscription = CompositeSubscription();

  void listenTo(Observable observable) {
    autoDispose(observable.listen((_) {
      // Refresh the state to rebuild the
      // widget.
      setState(() {});
    }));
  }

  void autoDispose(StreamSubscription subscription) {
    _compositeSubscription.add(subscription);
  }

  @override
  void dispose() {
    _compositeSubscription.clear();
    super.dispose();
  }
}
