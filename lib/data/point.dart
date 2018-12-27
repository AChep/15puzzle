import 'dart:math';

import 'package:fifteenpuzzle/utils/serializable.dart';

class PointSerializableWrapper extends Point<int> implements Serializable {
  PointSerializableWrapper(Point<int> point) : super(point.x, point.y);

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(x);
    output.writeInt(y);
  }
}

class PointDeserializableFactory extends DeserializableHelper<Point<int>> {
  const PointDeserializableFactory() : super();

  @override
  Point<int> deserialize(SerializeInput input) {
    final x = input.readInt();
    final y = input.readInt();
    return Point(x, y);
  }
}
