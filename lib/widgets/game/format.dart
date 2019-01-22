String formatElapsedTime(int millis) {
  final seconds = millis ~/ 1000;
  final fraction = millis % 1000 ~/ 100;

  final h = seconds ~/ 3600;
  final m = seconds ~/ 60 % 60;
  final s = seconds % 60;

  final suffix = '${s <= 9 ? '0$s' : '$s'}.$fraction';
  if (h > 0) {
    return '$h:${_withLeadingZero(m)}:$suffix';
  } else {
    // Include minutes and the suffix
    // part.
    return '$m:$suffix';
  }
}

String _withLeadingZero(int n) => n <= 9 ? '0$n' : '$n';
