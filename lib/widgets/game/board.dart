import 'dart:math';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/data/chip.dart';
import 'package:fifteenpuzzle/domain/game.dart';
import 'package:fifteenpuzzle/widgets/game/chip.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/widgets.dart';

class BoardWidget extends StatefulWidget {
  final Board board;

  final double size;

  final bool showNumbers;

  final Function(Point<int>) onTap;

  BoardWidget({
    Key key,
    @required this.board,
    @required this.size,
    this.showNumbers = true,
    this.onTap,
  }) : super(key: key);

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  static const _ANIM_COLOR_TAG = "color";
  static const _ANIM_MOVE_TAG = "move";
  static const _ANIM_SCALE_TAG = "scale";

  List<_Chip> chips;

  Function(double, double) _onPanEndDelegate;

  Function(double, double) _onPanUpdateDelegate;

  @override
  void initState() {
    super.initState();
    _performSetBoard(
      newBoard: widget.board,
    );
  }

  @override
  void didUpdateWidget(BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _performSetBoard(
      newBoard: widget.board,
      oldBoard: oldWidget.board,
    );
  }

  void _performSetPrevBoard() =>
      _performSetBoard(newBoard: widget.board, oldBoard: widget.board);

  void _performSetBoard({final Board newBoard, final Board oldBoard}) {
    if (newBoard == null) {
      setState(() {
        // Dispose current animations. This is not necessary, but good
        // to do.
        chips?.forEach((chip) {
          chip.animations.values.forEach((controller) => controller.dispose());
        });

        chips = null;
      });
      return;
    }

    final board = newBoard;
    if (chips == null || board.chips.length != oldBoard.chips.length) {
      // The size of the board has been changed...
      // rebuild everything!
      setState(() {
        // Create our extras
        final hueStep = 360 / board.chips.length;
        chips = board.chips.map((chip) {
          final x = chip.currentPoint.x / board.size;
          final y = chip.currentPoint.y / board.size;
          final color =
              HSLColor.fromAHSL(1, hueStep * chip.number, 0.7, 0.5).toColor();
          return _Chip(x, y, chip.currentPoint, backgroundColor: color);
        }).toList(growable: false);
      });
      return;
    }

    for (var chip in board.chips) {
      final extra = chips[chip.number];
      if (extra.currentPoint != chip.currentPoint || extra.touched) {
        // The chip has been moved somewhere...
        // animate the change!
        final wasTouched = extra.touched;
        final wasCurrentPoint = extra.currentPoint;
        extra.touched = false;
        extra.currentPoint = chip.currentPoint;
        _onChipChange(chip, wasCurrentPoint, chip.currentPoint,
            enableColorAnimation: !wasTouched);
      }
    }
  }

  void _onChipChange(
    Chip chip,
    Point<int> from,
    Point<int> to, {
    bool enableColorAnimation = true,
  }) {
    if (from.x != to.x && from.y != to.y) {
      // Chip can not be physically moved this way, play
      // the blink animation along with move animation.
      _startBlinkAnimation(chip, to);
    } else {
      _startMoveAnimation(chip, to);
    }

    if (enableColorAnimation) _startColorAnimation(chip, to);
  }

  void _startMoveAnimation(Chip chip, Point<int> point) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final target = chips[chip.number];
    final animation = CurvedAnimation(
      parent: controller,
      curve: ElasticOutCurve(1.0),
    );

    final board = widget.board;
    final oldX = target.x * board.size;
    final oldY = target.y * board.size;
    animation.addListener(() {
      // Calculate current point
      // of the chip.
      final x = (oldX * (1.0 - animation.value) + point.x * animation.value) /
          board.size;
      final y = (oldY * (1.0 - animation.value) + point.y * animation.value) /
          board.size;

      setState(() {
        target.x = x;
        target.y = y;
      });
    });

    // Start and dispose the animation
    // after its finish.
    _addAnimation(chip, _ANIM_MOVE_TAG, controller);
    controller
        .forward()
        .then<void>((_) => _disposeAnimation(chip, _ANIM_MOVE_TAG));
  }

  void _startBlinkAnimation(Chip chip, Point<int> point) {
    final duration = const Duration(milliseconds: 400);
    final curve = Curves.easeInOut;

    void _startScaleAnimation(Chip chip, Point<int> point) {
      final controller = AnimationController(
        duration: duration,
        vsync: this,
      );

      final target = chips[chip.number];
      final animation = CurvedAnimation(
        parent: controller,
        curve: curve,
      );
      animation.addListener(() {
        final scale = cos(animation.value * 2.0 * pi) / 2.0 + 0.5;
        setState(() {
          target.scale = scale;
        });
      });

      _addAnimation(chip, _ANIM_SCALE_TAG, controller);
      controller
          .forward()
          .then<void>((_) => _disposeAnimation(chip, _ANIM_SCALE_TAG));
    }

    void _startMoveAnimation(Chip chip, Point<int> point) {
      final controller = AnimationController(
        duration: duration,
        vsync: this,
      );

      final target = chips[chip.number];
      final animation = CurvedAnimation(
        parent: controller,
        curve: curve,
      );

      final board = widget.board;
      var wasHalfwayOrMore = false;
      animation.addListener(() {
        final isHalfwayOrMore = animation.value >= 0.5;
        if (isHalfwayOrMore != wasHalfwayOrMore) {
          wasHalfwayOrMore = isHalfwayOrMore;

          final x = point.x.toDouble() / board.size;
          final y = point.y.toDouble() / board.size;
          setState(() {
            target.x = x;
            target.y = y;
          });
        }
      });

      _addAnimation(chip, _ANIM_MOVE_TAG, controller);
      controller
          .forward()
          .then<void>((_) => _disposeAnimation(chip, _ANIM_MOVE_TAG));
    }

    _startScaleAnimation(chip, point);
    _startMoveAnimation(chip, point);
  }

  void _startColorAnimation(Chip chip, Point<int> point) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final target = chips[chip.number];
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    animation.addListener(() {
      final opacity = sin(sqrt(animation.value) * pi) * 0.15;
      setState(() {
        target.overlayColor = Color.fromRGBO(255, 255, 255, opacity);
      });
    });

    _addAnimation(chip, _ANIM_COLOR_TAG, controller);
    controller
        .forward()
        .then<void>((_) => _disposeAnimation(chip, _ANIM_COLOR_TAG));
  }

  void _addAnimation(
    Chip chip,
    String tag,
    AnimationController controller,
  ) {
    final map = chips[chip.number].animations;

    // Replace previous animation.
    map[tag]?.dispose();
    map[tag] = controller;
  }

  void _disposeAnimation(
    Chip chip,
    String tag,
  ) {
    final map = chips[chip.number].animations;
    map.remove(tag)?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    if (board == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text('Empty board'),
        ),
      );
    }
    final chips = board.chips.map(_buildChipWidget).toList();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (DragStartDetails details) => onPanStart(context, details),
        onPanCancel: onPanCancel,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Stack(children: chips),
      ),
    );
  }

  Widget _buildChipWidget(Chip chip) {
    final board = widget.board;
    final extra = chips[chip.number];

    // Calculate the distance between current absolute position
    // and target position.
    final dstHorizontal = extra.x * board.size - chip.targetPoint.x;
    final dstVertical = extra.y * board.size - chip.targetPoint.y;
    final dst = sqrt(pow(dstHorizontal, 2) + pow(dstVertical, 2));

    // Calculate the colors.
    final overlayColor = extra.overlayColor;
    final backgroundColor =
        extra.backgroundColor.withOpacity(dst < 1 ? 1 - dst : 0);

    final chipSize = widget.size / board.size;
    return Positioned(
      width: chipSize,
      height: chipSize,
      left: extra.x * widget.size,
      top: extra.y * widget.size,
      child: Transform.scale(
        scale: extra.scale,
        child: ChipWidget(
          chip,
          overlayColor,
          backgroundColor,
          chipSize / 3,
          showNumber: widget.showNumbers,
          size: widget.size,
          onPressed: widget.onTap != null
              ? () {
                  widget.onTap(chip.currentPoint);
                }
              : null,
        ),
      ),
    );
  }

  void onPanStart(BuildContext context, DragStartDetails details) {
    final board = widget.board;

    if (board == null || chips == null) {
      _onPanUpdateDelegate = null;
      _onPanEndDelegate = null;
      return;
    }

    final boardWidgetSize = widget.size;
    final chipWidgetSize = boardWidgetSize / board.size;

    final RenderBox box = context.findRenderObject();
    final localPos = box.globalToLocal(details.globalPosition);
    final touchX = localPos.dx;
    final touchY = localPos.dy;

    _Chip activeChip;
    for (_Chip chip in chips) {
      if (chip.x * boardWidgetSize <= touchX &&
          chip.x * boardWidgetSize + chipWidgetSize >= touchX &&
          chip.y * boardWidgetSize <= touchY &&
          chip.y * boardWidgetSize + chipWidgetSize >= touchY) {
        activeChip = chip;
        break;
      }
    }

    if (activeChip == null) {
      _onPanUpdateDelegate = null;
      _onPanEndDelegate = null;
      return;
    }

    final game = Game.instance;

    // Calculate the range of possible movement of
    // a touched chip.
    final aPointInt = activeChip.currentPoint;
    final aPoint =
        Point<double>(aPointInt.x.toDouble(), aPointInt.y.toDouble());
    final aPointScaled = aPoint * chipWidgetSize;
    final bPointInt = game.findChipPositionAfterTap(board, point: aPointInt);
    final bPoint =
        Point<double>(bPointInt.x.toDouble(), bPointInt.y.toDouble());
    final bPointScaled = bPoint * chipWidgetSize;

    Point<double> fromPointScaled;
    Point<double> toPointScaled;
    if (aPoint.x > bPoint.x || aPoint.y > bPoint.y) {
      fromPointScaled = bPointScaled;
      toPointScaled = aPointScaled;
    } else {
      fromPointScaled = aPointScaled;
      toPointScaled = bPointScaled;
    }

    // Find the dependent on this movement chips.
    final group =
        (game.findChips(board, point: activeChip.currentPoint).toList()
              ..sort((a, b) {
                final aDst = a.currentPoint.distanceTo(aPointInt);
                final bDst = b.currentPoint.distanceTo(aPointInt);
                return aDst.compareTo(bDst);
              }))
            .map((chip) =>
                chips.firstWhere((c) => chip.currentPoint == c.currentPoint))
            .toList();

    //
    // Create an update delegate
    //

    _onPanUpdateDelegate = (double dx, double dy) {
      final x = max(min(activeChip.x * boardWidgetSize + dx, toPointScaled.x),
              fromPointScaled.x) /
          boardWidgetSize;
      final y = max(min(activeChip.y * boardWidgetSize + dy, toPointScaled.y),
              fromPointScaled.y) /
          boardWidgetSize;

      setState(() {
        activeChip.x = x;
        activeChip.y = y;

        activeChip.touched = true;
        activeChip.animations.remove(_ANIM_MOVE_TAG)?.dispose();

        for (int i = 1; i < group.length; i++) {
          final _Chip prev = group[i - 1];
          final _Chip next = group[i];

          if (prev.currentPoint.x != next.currentPoint.x) {
            var dx = chipWidgetSize - (next.x - prev.x).abs() * boardWidgetSize;
            if (dx > 0) {
              if (next.currentPoint.x > prev.currentPoint.x) {
                next.x = (next.x * boardWidgetSize + dx) / boardWidgetSize;
              } else {
                next.x = (next.x * boardWidgetSize - dx) / boardWidgetSize;
              }

              next.touched = true;
              next.animations.remove(_ANIM_MOVE_TAG)?.dispose();
            }
          } else {
            var dy = chipWidgetSize - (next.y - prev.y).abs() * boardWidgetSize;
            if (dy > 0) {
              if (next.currentPoint.y > prev.currentPoint.y) {
                next.y = (next.y * boardWidgetSize + dy) / boardWidgetSize;
              } else {
                next.y = (next.y * boardWidgetSize - dy) / boardWidgetSize;
              }

              next.touched = true;
              next.animations.remove(_ANIM_MOVE_TAG)?.dispose();
            }
          }
        }
      });
    };

    //
    // Create an end delegate
    //

    _onPanEndDelegate = (double vx, double vy) {
      // TODO: Use the velocity to preform a fling.

      // Convert this gesture into a single tap
      // and clean-up delegates.
      final newTouchChipPoint = Point(
        (activeChip.x * board.size).round(),
        (activeChip.y * board.size).round(),
      );

      if (newTouchChipPoint != activeChip.currentPoint) {
        widget.onTap(activeChip.currentPoint);
      } else if (group.length >= 2) {
        final nextToTouchChip = group[1];
        final nextToTouchChipPoint = Point(
          (nextToTouchChip.x * board.size).round(),
          (nextToTouchChip.y * board.size).round(),
        );

        if (nextToTouchChipPoint != nextToTouchChip.currentPoint) {
          widget.onTap(nextToTouchChip.currentPoint);
        } else {
          _performSetPrevBoard();
        }
      } else {
        _performSetPrevBoard();
      }

      // Clean-up delegates
      _onPanEndDelegate = null;
      _onPanUpdateDelegate = null;
    };
  }

  void onPanCancel() {
    if (_onPanEndDelegate == null && _onPanUpdateDelegate == null) {
      return;
    }

    _onPanEndDelegate = null;
    _onPanUpdateDelegate = null;

    _performSetPrevBoard();
  }

  void onPanUpdate(DragUpdateDetails details) {
    _onPanUpdateDelegate?.call(
      details.delta.dx,
      details.delta.dy,
    );
  }

  void onPanEnd(DragEndDetails details) {
    _onPanEndDelegate?.call(
      details.velocity.pixelsPerSecond.dx,
      details.velocity.pixelsPerSecond.dy,
    );
  }
}

class _Chip {
  double x = 0;
  double y = 0;

  bool touched = false;

  /// Current X and Y scale of the chip, used for a
  /// blink animation.
  double scale = 1;

  Color backgroundColor = Colors.white.withOpacity(0.0);

  Color overlayColor = Colors.white.withOpacity(0.0);

  Map<String, AnimationController> animations = Map();

  Point<int> currentPoint;

  _Chip(this.x, this.y, this.currentPoint, {this.backgroundColor});
}
