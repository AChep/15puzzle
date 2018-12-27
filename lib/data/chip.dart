import 'dart:math';

import 'package:fifteenpuzzle/utils/serializable.dart';

import 'point.dart';

class Chip {
  /// Unique identifier of a chip, starts
  /// from a zero.
  final int number;

  final Point<int> targetPoint;

  final Point<int> currentPoint;

  const Chip(
    this.number,
    this.targetPoint,
    this.currentPoint,
  );

  Chip move(Point<int> point) => Chip(number, targetPoint, point);
}

class ChipDeserializableFactory extends DeserializableHelper<Chip> {
  @override
  Chip deserialize(SerializeInput input) {
    final pd = DeserializablePointHelper();

    final number = input.readInt();
    final targetPoint = input.readDeserializable(pd);
    final currentPoint = input.readDeserializable(pd);
    return Chip(number, targetPoint, currentPoint);
  }
}
