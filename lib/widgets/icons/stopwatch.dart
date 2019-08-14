import 'dart:math';

import 'package:flutter/widgets.dart';

class StopwatchIcon extends StatelessWidget {
  final double size;

  final int millis;

  final Color color;

  StopwatchIcon({
    @required this.size,
    @required this.millis,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StopwatchPainter(millis, color),
      ),
    );
  }
}

class _StopwatchPainter extends CustomPainter {
  final Paint stopwatchPaint;

  final int millis;

  _StopwatchPainter(this.millis, final Color color) : stopwatchPaint = Paint() {
    stopwatchPaint.color = color;
    stopwatchPaint.strokeWidth = 2.0;
    stopwatchPaint.style = PaintingStyle.stroke;
    stopwatchPaint.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    canvas.drawCircle(center, radius, stopwatchPaint);
    canvas.translate(center.dx, center.dy);

    final o = Offset(0, 0);

    // Minutes
    canvas.save();
    canvas.rotate(_calculateMinuteHandRotation(millis));
    canvas.drawLine(o, o.translate(0, -radius / 1.7 + 2), stopwatchPaint);
    canvas.restore();

    // Seconds
    canvas.save();
    canvas.rotate(_calculateSecondHandRotation(millis));
    canvas.drawLine(o, o.translate(0, -radius / 1.25 + 2), stopwatchPaint);
    canvas.restore();
  }

  double _calculateMinuteHandRotation(int millis) {
    final seconds = millis / 1000.0;
    final degrees = (seconds % 3600.0) / 10.0;
    return degrees * 2.0 * pi / 360.0;
  }

  double _calculateSecondHandRotation(int millis) {
    final seconds = millis / 1000.0;
    final degrees = (seconds % 60.0) * 6.0;
    return degrees * 2.0 * pi / 360.0;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
