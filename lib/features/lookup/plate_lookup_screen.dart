import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import 'bus_profile_screen.dart';
import 'qr_scan_screen.dart';

class PlateLookupScreen extends StatefulWidget {
  const PlateLookupScreen({super.key});

  @override
  State<PlateLookupScreen> createState() => _PlateLookupScreenState();
}

class _PlateLookupScreenState extends State<PlateLookupScreen> {
  final _plateController = TextEditingController();
  final _firestore = FirestoreService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _searchPlate() async {
    final raw = _plateController.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Please enter a bus plate number (e.g. WXY 1234).');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bus = await _firestore.getBusByPlate(raw);
      if (!mounted) return;

      if (bus == null) {
        setState(() => _error = 'No bus found with plate "$raw".');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BusProfileScreen(bus: bus)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Lookup failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _scanQr() async {
    final busId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (busId == null || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bus = await _firestore.getBusById(busId);
      if (!mounted) return;

      if (bus == null) {
        setState(() => _error = 'No bus found for QR "$busId".');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BusProfileScreen(bus: bus)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'QR lookup failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8),
      body: Column(
        children: [
          // Dark Emerald Safety Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F6E5C),
                  Color(0xFF0B2E26),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plate Lookup',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Enter a Malaysian bus plate number or scan the bus QR code.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // White Search Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B2E26).withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Bus Plate Number',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B2E26),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _plateController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchPlate(),
                          decoration: InputDecoration(
                            hintText: 'e.g. WXY 1234',
                            prefixIcon: const Icon(
                              Icons.directions_bus_rounded,
                              color: Color(0xFF1F6E5C),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Primary Search Pill Button
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0B2E26),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _loading ? null : _searchPlate,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                          label: Text(
                            _loading ? 'Searching...' : 'Search Bus',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Secondary QR Scan Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1F6E5C),
                            side: const BorderSide(
                              color: Color(0xFF1F6E5C),
                              width: 1.4,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _loading ? null : _scanQr,
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text(
                            'Scan Bus QR Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Inline Error Banner
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Helpful Tip Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF1F6E5C),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Spaces and lowercase letters are handled automatically — e.g. "wxy1234" works too.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF0B2E26),
                              height: 1.4,
                            ),
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
