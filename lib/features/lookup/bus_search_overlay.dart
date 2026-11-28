import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted-glass searching overlay with a folded map & orbiting magnifying glass.
class BusSearchOverlay extends StatefulWidget {
  final String message;

  const BusSearchOverlay({
    super.key,
    this.message = 'Searching your bus...',
  });

  @override
  State<BusSearchOverlay> createState() => _BusSearchOverlayState();
}

class _BusSearchOverlayState extends State<BusSearchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.white.withValues(alpha: 0.72),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 210,
                height: 140,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value * 2 * math.pi;
                    // Smooth figure-8 / elliptical search path over the map
                    final dx = math.cos(t) * 34;
                    final dy = math.sin(t * 2) * 14;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Folded map with roads & pins
                        CustomPaint(
                          size: const Size(190, 115),
                          painter: _FoldedMapPainter(),
                        ),
                        // Orbiting magnifying glass
                        Transform.translate(
                          offset: Offset(dx, dy - 6),
                          child: CustomPaint(
                            size: const Size(64, 82),
                            painter: _MagnifierPainter(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B2E26),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a 3-panel folded map in Emerald Safety tones with roads & pins.
class _FoldedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final panelW = w / 3;

    // 3 folded panels (alternating slightly for a 3D accordion look)
    final p1 = Path()
      ..moveTo(6, 10)
      ..lineTo(panelW, 0)
      ..lineTo(panelW, h - 10)
      ..lineTo(0, h)
      ..close();

    final p2 = Path()
      ..moveTo(panelW, 0)
      ..lineTo(panelW * 2, 10)
      ..lineTo(panelW * 2, h)
      ..lineTo(panelW, h - 10)
      ..close();

    final p3 = Path()
      ..moveTo(panelW * 2, 10)
      ..lineTo(w - 6, 0)
      ..lineTo(w, h - 10)
      ..lineTo(panelW * 2, h)
      ..close();

    // Soft drop shadow
    canvas.drawShadow(p1, Colors.black26, 6, false);
    canvas.drawShadow(p2, Colors.black26, 6, false);
    canvas.drawShadow(p3, Colors.black26, 6, false);

    // Panel fills (soft mint / sage emerald)
    canvas.drawPath(p1, Paint()..color = const Color(0xFFD1FAE5));
    canvas.drawPath(p2, Paint()..color = const Color(0xFFA7F3D0));
    canvas.drawPath(p3, Paint()..color = const Color(0xFFD1FAE5));

    // White road lines
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(14, h * 0.35)
        ..quadraticBezierTo(w * 0.45, h * 0.25, w * 0.88, h * 0.55),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, 12)
        ..lineTo(w * 0.48, h - 14),
      roadPaint..strokeWidth = 2.5,
    );

    // Bus stop / route pins
    final pins = [
      Offset(w * 0.22, h * 0.42),
      Offset(w * 0.52, h * 0.34),
      Offset(w * 0.78, h * 0.48),
      Offset(w * 0.44, h * 0.70),
    ];
    for (final pos in pins) {
      canvas.drawCircle(pos, 5.5, Paint()..color = const Color(0xFF1F6E5C));
      canvas.drawCircle(pos, 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws a clean dark-emerald magnifying glass with a frosted lens highlight.
class _MagnifierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lensCenter = Offset(size.width * 0.55, size.height * 0.35);
    const radius = 21.0;

    // Handle
    canvas.drawLine(
      Offset(lensCenter.dx - 13, lensCenter.dy + 15),
      Offset(lensCenter.dx - 26, lensCenter.dy + 42),
      Paint()
        ..color = const Color(0xFF0B2E26)
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round,
    );

    // Translucent glass fill
    canvas.drawCircle(
      lensCenter,
      radius,
      Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.28),
    );

    // Dark emerald rim
    canvas.drawCircle(
      lensCenter,
      radius,
      Paint()
        ..color = const Color(0xFF0B2E26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );

    // Specular glass shine
    canvas.drawArc(
      Rect.fromCircle(center: lensCenter, radius: radius - 5),
      -math.pi * 0.8,
      math.pi * 0.35,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
