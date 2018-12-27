import 'dart:math';

import 'package:fifteenpuzzle/utils/serializable.dart';

class DeserializablePointHelper extends DeserializableHelper<Point<int>> {
  @override
  Point<int> deserialize(SerializeInput input) {
    final x = input.readInt();
    final y = input.readInt();
    return Point(x, y);
  }
}
