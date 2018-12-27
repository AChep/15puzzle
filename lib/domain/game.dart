import 'dart:math';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/data/chip.dart';
import 'package:meta/meta.dart';

abstract class Game {
  static Game instance = _GameImpl();

  /// Randomly shuffles the chips on a board, for
  /// a given amount of times.
  Board shuffle(Board board, {int amount = 300});

  Board tap(Board board, {@required Point<int> point});

  /// Returns the chips that are free to move,
  /// including a chip at the point.
  Iterable<Chip> findChips(Board board, {@required Point<int> point});
}

class _GameImpl implements Game {
  @override
  Board shuffle(Board board, {int amount = 300}) {
    final random = Random();

    List<List<Chip>> matrix = List.generate(board.size, (i) {
      return List.generate(board.size, (j) {
        return null;
      });
    });

    board.chips.forEach((chip) {
      final pos = chip.currentPoint;
      matrix[pos.x][pos.y] = chip;
    });

    // Perform the shuffling
    var blankX = board.blank.x;
    var blankY = board.blank.y;
    for (var n = 0; n < amount; n++) {
      var x = blankX;
      var y = blankY;
      switch (random.nextInt(4)) {
        case 0: // top
          y--;
          break;
        case 1: // right
          x++;
          break;
        case 2: // bottom
          y++;
          break;
        case 3: // left
          x--;
          break;
        default:
          throw StateError("You have choosen an uknown direction.");
          break;
      }

      if (x < 0 || x >= board.size || y < 0 || y >= board.size) {
        // We can not get out of the board.
        continue;
      }

      matrix[blankX][blankY] = matrix[x][y];
      matrix[x][y] = null;

      blankX = x;
      blankY = y;
    }

    // Apply new chips positions
    final blank = Point(blankX, blankY);
    final chips = List.of(board.chips, growable: false);
    for (var x = 0; x < board.size; x++) {
      for (var y = 0; y < board.size; y++) {
        final chip = matrix[x][y];
        if (chip != null) {
          chips[chip.number] = chip.move(Point(x, y));
        }
      }
    }

    return Board(board.size, chips, blank);
  }

  @override
  Board tap(Board board, {Point<int> point}) {
    int dx;
    int dy;
    if (point.x == board.blank.x) {
      dx = 0;
      dy = point.y > board.blank.y ? -1 : 1;
    } else if (point.y == board.blank.y) {
      dx = point.x > board.blank.x ? -1 : 1;
      dy = 0;
    } else {
      return board;
    }

    final blank = point;
    final chips = List.of(board.chips, growable: false);
    findChips(board, point: point).forEach((chip) {
      chips[chip.number] = chip.move(chip.currentPoint + Point(dx, dy));
    });

    return Board(board.size, chips, blank);
  }

  @override
  Iterable<Chip> findChips(Board board, {Point<int> point}) {
    if (point.x == board.blank.x) {
      int start;
      int end;
      if (point.y > board.blank.y) {
        start = board.blank.y + 1;
        end = point.y;
      } else {
        start = point.y;
        end = board.blank.y - 1;
      }

      return board.chips.where((chip) {
        final x = chip.currentPoint.x;
        final y = chip.currentPoint.y;
        return x == board.blank.x && y >= start && y <= end;
      });
    } else if (point.y == board.blank.y) {
      int start;
      int end;
      if (point.x > board.blank.x) {
        start = board.blank.x + 1;
        end = point.x;
      } else {
        start = point.x;
        end = board.blank.x - 1;
      }

      return board.chips.where((chip) {
        final x = chip.currentPoint.x;
        final y = chip.currentPoint.y;
        return y == board.blank.y && x >= start && x <= end;
      });
    } else {
      return Iterable.empty();
    }
  }
}
