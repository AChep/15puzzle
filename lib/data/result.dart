import 'package:meta/meta.dart';

@immutable
class Result {
  final int steps;
  final int time;
  final int size;

  Result({@required this.steps, @required this.time, @required this.size});
}
