import 'dart:math';

import 'package:fifteenpuzzle/data/board.dart';
import 'package:fifteenpuzzle/data/chip.dart';
import 'package:fifteenpuzzle/widgets/game/chip.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/widgets.dart';

class BoardWidget extends StatefulWidget {
  final Board board;

  final double size;

  BoardWidget({
    Key key,
    @required this.board,
    @required this.size,
  }) : super(key: key);

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  static const _ANIM_COLOR_TAG = "color";
  static const _ANIM_MOVE_TAG = "move";
  static const _ANIM_SCALE_TAG = "scale";

  AnimationController controller;

  List<_Chip> chips;

  @override
  void didUpdateWidget(BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final board = widget.board;
    if (chips == null || board.chips.length != oldWidget.board.chips.length) {
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
      if (extra.currentPoint != chip.currentPoint) {
        // The chip has been moved somewhere...
        // animate the change!
        final from = extra.currentPoint;
        extra.currentPoint = chip.currentPoint;
        _onChipChange(chip, from, chip.currentPoint);
      }
    }
  }

  void _onChipChange(Chip chip, Point<int> from, Point<int> to) {
    if (from.x != to.x && from.y != to.y) {
      // Chip can not be physically moved this way, play
      // the blink animation along with move animation.
      _startBlinkAnimation(chip, to);
    } else {
      _startMoveAnimation(chip, to);
    }

    _startColorAnimation(chip, to);
  }

  void _startMoveAnimation(Chip chip, Point<int> point) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      );
    }
    final chips = board.chips.map(_buildChipWidget).toList();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(children: chips),
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
          onPressed: () {},
        ),
      ),
    );
  }
}

class _Chip {
  double x = 0;
  double y = 0;

  /// Current X and Y scale of the chip, used for a
  /// blink animation.
  double scale = 1;

  Color backgroundColor = Colors.white.withOpacity(0.0);

  Color overlayColor = Colors.white.withOpacity(0.0);

  Map<String, AnimationController> animations = Map();

  Point<int> currentPoint;

  _Chip(this.x, this.y, this.currentPoint, {this.backgroundColor});
}
