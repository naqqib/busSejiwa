import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crisp 4-color Google "G" icon for Sign-In buttons.
class GoogleGLogo extends StatelessWidget {
  final double size;
  const GoogleGLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.21;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - stroke) / 2,
    );

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // 4 official Google brand arcs
    canvas.drawArc(rect, -0.78, 1.56, false, arcPaint(const Color(0xFF4285F4))); // Blue
    canvas.drawArc(rect, 0.78, 1.57, false, arcPaint(const Color(0xFF34A853)));  // Green
    canvas.drawArc(rect, 2.35, 1.38, false, arcPaint(const Color(0xFFFBBC05)));  // Yellow
    canvas.drawArc(rect, 3.73, 1.77, false, arcPaint(const Color(0xFFEA4335)));  // Red

    // Blue horizontal crossbar of the "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.50),
      Offset(size.width * 0.98, size.height * 0.50),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
