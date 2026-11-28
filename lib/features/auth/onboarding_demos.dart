import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared frosted-glass stage for all 3 onboarding mini-demos.
class _DemoStage extends StatelessWidget {
  final Widget child;
  const _DemoStage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(
          color: const Color(0xFF6EE7B7).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

// =============================================================================
// DEMO 1: Animated QR Scanner Laser
// =============================================================================
class QrScanDemo extends StatefulWidget {
  const QrScanDemo({super.key});

  @override
  State<QrScanDemo> createState() => _QrScanDemoState();
}

class _QrScanDemoState extends State<QrScanDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoStage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 118,
            height: 118,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 108,
                  color: Colors.white.withValues(alpha: 0.90),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment(0, -1.0 + _controller.value * 2.0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: const Color(0xFF6EE7B7),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.95),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'WXY 1234 • Verified',
              style: TextStyle(
                color: Color(0xFF6EE7B7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DEMO 2: Live Safety Rating Counter + Pulsing Ring
// =============================================================================
class LiveRatingDemo extends StatefulWidget {
  const LiveRatingDemo({super.key});

  @override
  State<LiveRatingDemo> createState() => _LiveRatingDemoState();
}

class _LiveRatingDemoState extends State<LiveRatingDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Sweeps smoothly between 62.0 (Amber) and 88.5 (Emerald)
    _scoreAnim = Tween<double>(begin: 62.0, end: 88.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoStage(
      child: AnimatedBuilder(
        animation: _scoreAnim,
        builder: (context, _) {
          final score = _scoreAnim.value;
          final isSafe = score >= 80;
          final ringColor =
              isSafe ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 116,
                height: 116,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 116,
                      height: 116,
                      child: CircularProgressIndicator(
                        value: score / 100.0,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: ringColor,
                          ),
                        ),
                        const Text(
                          '/ 100',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ringColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSafe ? 'LIVE • SAFE' : 'LIVE • CAUTION',
                    style: TextStyle(
                      color: ringColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// DEMO 3: Speedometer Needle & Over-Limit Alert
// =============================================================================
class SpeedAlertDemo extends StatefulWidget {
  const SpeedAlertDemo({super.key});

  @override
  State<SpeedAlertDemo> createState() => _SpeedAlertDemoState();
}

class _SpeedAlertDemoState extends State<SpeedAlertDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _speedAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Sweeps from 70 km/h (safe) -> 115 km/h (over 90 km/h bus limit)
    _speedAnim = Tween<double>(begin: 70, end: 115).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoStage(
      child: AnimatedBuilder(
        animation: _speedAnim,
        builder: (context, _) {
          final speed = _speedAnim.value;
          final isSpeeding = speed > 90;
          final badgeColor =
              isSpeeding ? const Color(0xFFF87171) : const Color(0xFF6EE7B7);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 82,
                child: CustomPaint(
                  painter: _SpeedGaugePainter(speed: speed),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${speed.toStringAsFixed(0)} km/h',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  isSpeeding ? 'OVER 90 KM/H LIMIT' : 'WITHIN SPEED LIMIT',
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Draws a semi-circular speedometer arc (green -> amber -> red) + moving needle.
class _SpeedGaugePainter extends CustomPainter {
  final double speed; // 0..140 km/h
  _SpeedGaugePainter({required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 6);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // 3 colored speed zones across 180 degrees (pi radians)
    canvas.drawArc(rect, math.pi, math.pi * 0.55, false, arc(const Color(0xFF10B981)));
    canvas.drawArc(rect, math.pi * 1.57, math.pi * 0.16, false, arc(const Color(0xFFFBBF24)));
    canvas.drawArc(rect, math.pi * 1.75, math.pi * 0.25, false, arc(const Color(0xFFEF4444)));

    // Needle angle mapped from 0..140 km/h across pi..2*pi
    final ratio = (speed / 140.0).clamp(0.0, 1.0);
    final angle = math.pi + (ratio * math.pi);
    final needleTip = Offset(
      center.dx + (radius - 14) * math.cos(angle),
      center.dy + (radius - 14) * math.sin(angle),
    );

    canvas.drawLine(
      center,
      needleTip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) =>
      oldDelegate.speed != speed;
}
