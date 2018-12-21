import 'dart:math';

import 'package:fifteenpuzzle/game/logic/chip.dart';
import 'package:fifteenpuzzle/game/logic/game.dart';
import 'package:fifteenpuzzle/utils/state.dart';
import 'package:fifteenpuzzle/widgets/chip.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/widgets.dart';
/*
class BoardWidget extends StatefulWidget {
  final Game game;

  BoardWidget({Key key, @required this.game}) : super(key: key);

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends AutoDisposableState<BoardWidget>
    with TickerProviderStateMixin {
  static const _ANIM_COLOR_TAG = "color";
  static const _ANIM_MOVE_TAG = "move";
  static const _ANIM_SCALE_TAG = "scale";

  AnimationController controller;

  List<_BoardChip> chips;

  List<Color> colors;

  @override
  void initState() {
    super.initState();
    // Listen to the chips changes.
    final chips = widget.game.board.chips;
    chips.forEach(
        (chip) => autoDispose(chip.currentPositionSubject.listen((point) {
              _onChipChange(chip, point);
            })));

    this.chips = chips.map((chip) {
      final x = chip.currentPositionSubject.value.x / widget.game.board.size;
      final y = chip.currentPositionSubject.value.y / widget.game.board.size;
      return _BoardChip(x, y)
      ..old = chip.currentPositionSubject.value;
    }).toList(growable: false);

    final hueDx = 360 / chips.length;
    this.colors = chips.map((chip) {
      return HSLColor.fromAHSL(1, hueDx * chip.number, 0.7, 0.5).toColor();
    }).toList(growable: false);
  }

  void _onChipChange(Chip chip, Point<int> point) {
    final old = this.chips[chip.number].old;
    this.chips[chip.number].old = point;

    if (old.x != point.x && old.y != point.y) {
      // Chip can not be physically moved this way, play
      // the blink animation along with move animation.
      _startBlinkAnimation(chip, point);
    } else {
      _startMoveAnimation(chip, point);
    }

    _startColorAnimation(chip, point);
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

    final oldX = target.x * widget.game.board.size;
    final oldY = target.y * widget.game.board.size;
    animation.addListener(() {
      // Calculate current point
      // of the chip.
      final x = (oldX * (1.0 - animation.value) + point.x * animation.value) /
          widget.game.board.size;
      final y = (oldY * (1.0 - animation.value) + point.y * animation.value) /
          widget.game.board.size;

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

      var wasHalfwayOrMore = false;
      animation.addListener(() {
        final isHalfwayOrMore = animation.value >= 0.5;
        if (isHalfwayOrMore != wasHalfwayOrMore) {
          wasHalfwayOrMore = isHalfwayOrMore;

          final x = point.x.toDouble() / widget.game.board.size;
          final y = point.y.toDouble() / widget.game.board.size;
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
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black12
        : Colors.black45;
    return Center(
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final puzzleSize = min(constraints.maxWidth, constraints.maxHeight);
            final chips = widget.game.board.chips.map((chip) {
              return _buildChipWidget(chip, puzzleSize);
            }).toList();
            return Container(
              width: puzzleSize,
              height: puzzleSize,
              child: Stack(
                children: chips,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChipWidget(Chip chip, num puzzleSize) {
    final c = chips[chip.number];
    final chipSize = puzzleSize / widget.game.board.size;

    // Calculate the distance between current absolute position
    // and target position.
    final dstHorizontal = c.x * widget.game.board.size - chip.targetPosition.x;
    final dstVertical = c.y * widget.game.board.size - chip.targetPosition.y;
    final dst = sqrt(pow(dstHorizontal, 2) + pow(dstVertical, 2));

    // Calculate the colors.
    final overlayColor = c.overlayColor;
    final backgroundColor =
        colors[chip.number].withOpacity(dst < 1 ? 1 - dst : 0);

    return Positioned(
      width: chipSize,
      height: chipSize,
      left: c.x * puzzleSize,
      top: c.y * puzzleSize,
      child: Transform.scale(
        scale: c.scale,
        child: ChipWidget(
          chip,
          overlayColor,
          backgroundColor,
          onPressed: () {
            widget.game.tap(chip.currentPositionSubject.value);
          },
        ),
      ),
    );
  }
}

class _BoardChip {
  double x = 0;
  double y = 0;

  /// Current X and Y scale of the chip, used for a
  /// blink animation.
  double scale = 1;

  Color overlayColor = Colors.white.withOpacity(0.0);

  Map<String, AnimationController> animations = Map();

  Point<int> old;

  _BoardChip(this.x, this.y);
}
*/