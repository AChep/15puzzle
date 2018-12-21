import 'dart:math';

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
