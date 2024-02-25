import 'dart:math';

import 'package:flutter/material.dart';

class SemiCircleMeter extends StatelessWidget {
  final double value;

  const SemiCircleMeter({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return CustomPaint(
          size: const Size(500, 250), // Size of the semi-circle
          painter: _SemiCirclePainter(value),
        );
      },
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double value;

  _SemiCirclePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = getColor(value)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    // Draw semi-circle
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi,
      pi,
      false,
      paint,
    );

    final needleAngle = pi * (1 - value);
    final needleLength = size.width / 2;
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    final needleStart = Offset(size.width / 2, size.height);
    final needleEnd = Offset(
      size.width / 2 + needleLength * cos(needleAngle),
      size.height - needleLength * sin(needleAngle),
    );

    // Draw needle
    canvas.drawLine(needleStart, needleEnd, needlePaint);
  }

  Color getColor(double loudness) {
    return ColorTween(begin: Colors.lightBlue, end: Colors.deepOrange).lerp(value)!;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
