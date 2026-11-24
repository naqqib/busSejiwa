import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scans a bus QR code and returns its raw value (the bus document ID).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  // Prevents calling Navigator.pop more than once for the same QR code.
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    // Grab the first scanned barcode's text, if any.
    final rawValue =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) return;

    _handled = true;

    Navigator.pop(context, rawValue.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Bus QR Code')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
