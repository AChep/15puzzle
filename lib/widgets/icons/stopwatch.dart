import 'package:flutter/widgets.dart';

class StopwatchIcon extends StatelessWidget {
  final double size;

  final int millis;

  StopwatchIcon({@required this.size, @required this.millis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(),
    );
  }
}

class _StopwatchPainter extends CustomPainter {

  final Paint stopwatchPaint;

  _StopwatchPainter(final Color color) : stopwatchPaint = Paint() {
    stopwatchPaint.color = color;
    stopwatchPaint.strokeWidth = 2.0;
    stopwatchPaint.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}
