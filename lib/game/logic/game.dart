import 'dart:math';

import 'package:rxdart/rxdart.dart';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/data/chip.dart';

class Game {
  /// Current board that is shown to a user. The
  /// board can be changed in runtime.
  final board = BehaviorSubject<Board>();

  final Function onTap;

  final Function onSolve;

  Game({this.onTap, this.onSolve, Board board}) {
    if (board != null) {
      this.board.value = board;
    }

    this.board.stream.listen((board) {
      // Every time check if the board is in solved
      // state now.
      if (board.isSolved()) onSolve?.call();
    });
  }

  /// Randomly shuffles the chips on a board, for
  /// a given amount of times.
  void shuffle({final int amount = 300}) {
    final boardOld = this.board.value;
    final random = Random();

    List<List<Chip>> matrix = List.generate(boardOld.size, (i) {
      return List.generate(boardOld.size, (j) {
        return null;
      });
    });

    boardOld.chips.forEach((chip) {
      final pos = chip.currentPoint;
      matrix[pos.x][pos.y] = chip;
    });

    // Perform the shuffling
    var blankX = boardOld.blank.x;
    var blankY = boardOld.blank.y;
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

      if (x < 0 || x >= boardOld.size || y < 0 || y >= boardOld.size) {
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
    final chips = List.of(boardOld.chips, growable: false);
    for (var x = 0; x < boardOld.size; x++) {
      for (var y = 0; y < boardOld.size; y++) {
        final chip = matrix[x][y];
        if (chip != null) {
          chips[chip.number] = chip.move(Point(x, y));
        }
      }
    }

    board.value = Board(boardOld.size, chips, blank);
  }

  void tap(final Point<int> point) {
    final boardOld = this.board.value;

    int dx;
    int dy;
    if (point.x == boardOld.blank.x) {
      dx = 0;
      dy = point.y > boardOld.blank.y ? -1 : 1;
    } else if (point.y == boardOld.blank.y) {
      dx = point.x > boardOld.blank.x ? -1 : 1;
      dy = 0;
    } else {
      return;
    }

    final blank = point;
    final chips = List.of(boardOld.chips, growable: false);
    findChips(point).forEach((chip) {
      chips[chip.number] = chip.move(chip.currentPoint + Point(dx, dy));
      print('ahahahahaha');
    }
        );

    onTap?.call();

    board.value = Board(boardOld.size, chips, blank);
  }

  /// Returns the chips that are free to move,
  /// including a chip at the point.
  Iterable<Chip> findChips(Point<int> point) {
    final board = this.board.value;
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

  void dispose() {
    board.close();
  }
}
