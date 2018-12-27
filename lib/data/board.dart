import 'dart:math';

import 'package:fifteenpuzzle/utils/serializable.dart';

import 'chip.dart';

class Board extends Serializable {
  /// Width and height of a board, for
  /// example 4x4.
  final int size;

  final List<Chip> chips;

  final Point<int> blank;

  Board(this.size, this.chips, this.blank);

  factory Board.create(int size, Point<int> Function(int) factory) {
    final blank = factory(size * size - 1);
    final chips = List<Chip>.generate(size * size - 1, (n) {
      final point = factory(n);
      return Chip(n, point, point);
    });
    return Board(size, chips, blank);
  }

  /// Returns `true` if all of the [chips] are in their
  /// target positions.
  bool isSolved() {
    for (var chip in chips) {
      if (chip.targetPoint != chip.currentPoint) return false;
    }
    return true;
  }

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(size);
    output.writeInt(blank.x);
    output.writeInt(blank.y);

    for (final chip in chips) {

    }
  }

  @override
  deserialize(SerializeInput input) {
    // TODO: implement deserialize
    return null;
  }
}
