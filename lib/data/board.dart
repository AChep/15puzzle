import 'dart:math';

import 'package:fifteenpuzzle/data/point.dart';
import 'package:fifteenpuzzle/utils/serializable.dart';
import 'package:meta/meta.dart';

import 'chip.dart';

@immutable
class Board extends Serializable {
  /// Width and height of a board, for
  /// example 4x4.
  final int size;

  final List<Chip> chips;

  final Point<int> blank;

  Board(this.size, this.chips, this.blank);

  factory Board.createNormal(int size) =>
      Board.create(size, (n) => Point(n % size, n ~/ size));

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
    output.writeSerializable(PointSerializableWrapper(blank));

    for (final chip in chips) {
      output.writeSerializable(chip);
    }
  }
}

class BoardDeserializableFactory extends DeserializableHelper<Board> {
  const BoardDeserializableFactory() : super();

  @override
  Board deserialize(SerializeInput input) {
    final size = input.readInt();
    if (size == null) {
      return null;
    }

    const pointFactory = PointDeserializableFactory();
    const chipFactory = ChipDeserializableFactory();

    final blank = input.readDeserializable(pointFactory);
    if (blank == null) {
      return null;
    }

    final chips = List<Chip>();
    final length = size * size - 1;
    for (var i = 0; i < length; i++) {
      final chip = input.readDeserializable(chipFactory);
      if (chip == null) {
        return null;
      }

      chips.add(chip);
    }

    // TODO: Verify if the loaded data is valid
    return Board(size, chips, blank);
  }
}
