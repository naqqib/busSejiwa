import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen Emerald Safety QR scanner that returns the scanned busId.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  late final AnimationController _scanLineController;

  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    // Prevent popping multiple times on consecutive camera frames
    if (_hasScanned) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    _hasScanned = true;
    Navigator.pop(context, rawValue);
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    const frameSize = 250.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Feed
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 2. Dimmed Overlay + Emerald Corner Brackets
          CustomPaint(
            painter: _ScannerOverlayPainter(frameSize: frameSize),
          ),

          // 3. Animated Glowing Emerald Scan Line inside the Frame
          Center(
            child: SizedBox(
              width: frameSize - 24,
              height: frameSize - 24,
              child: AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, _) {
                  return Align(
                    alignment: Alignment(
                      0,
                      // Maps 0.0..1.0 -> -1.0 (top) .. +1.0 (bottom)
                      -1.0 + (_scanLineController.value * 2.0),
                    ),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF6EE7B7),
                            Color(0xFFFFFFFF),
                            Color(0xFF6EE7B7),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.85),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Top Bar (Back Button + Title + Flashlight Toggle)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleControlButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Scan Bus QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _CircleControlButton(
                        icon: _torchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        active: _torchOn,
                        onPressed: _toggleTorch,
                      ),
                    ],
                  ),

                  // 5. Bottom Instruction Pill
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E26).withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF6EE7B7),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Align the bus QR code inside the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted dark circular button for Back / Torch controls.
class _CircleControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  const _CircleControlButton({
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: active
            ? const Color(0xFF10B981)
            : const Color(0xFF0B2E26).withValues(alpha: 0.72),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

/// Draws the dimmed backdrop cutout and 4 Emerald Safety corner brackets.
class _ScannerOverlayPainter extends CustomPainter {
  final double frameSize;

  _ScannerOverlayPainter({required this.frameSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cutoutRect = Rect.fromCenter(
      center: center,
      width: frameSize,
      height: frameSize,
    );
    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(24),
    );

    // Dim everything outside the rounded square cutout
    final backdropPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      backdropPath,
      cutoutPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0xFF0B2E26).withValues(alpha: 0.62),
    );

    // Draw 4 glowing Emerald corner brackets
    final bracketPaint = Paint()
      ..color = const Color(0xFF6EE7B7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;
    const r = 24.0;
    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final ri = cutoutRect.right;
    final b = cutoutRect.bottom;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l, t + cornerLen)
        ..lineTo(l, t + r)
        ..quadraticBezierTo(l, t, l + r, t)
        ..lineTo(l + cornerLen, t),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(ri - cornerLen, t)
        ..lineTo(ri - r, t)
        ..quadraticBezierTo(ri, t, ri, t + r)
        ..lineTo(ri, t + cornerLen),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l, b - cornerLen)
        ..lineTo(l, b - r)
        ..quadraticBezierTo(l, b, l + r, b)
        ..lineTo(l + cornerLen, b),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(ri - cornerLen, b)
        ..lineTo(ri - r, b)
        ..quadraticBezierTo(ri, b, ri, b - r)
        ..lineTo(ri, b - cornerLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.frameSize != frameSize;
}
