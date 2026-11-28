import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../lookup/bus_profile_screen.dart';
import '../lookup/plate_lookup_screen.dart';
import '../lookup/qr_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  int _selectedTab = 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    return user?.email?.split('@').first ?? 'Passenger';
  }

  /// Opens QrScanScreen, fetches the scanned bus, and navigates to BusProfileScreen.
  Future<void> _openQrScanner() async {
    final busId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (busId == null || !mounted) return;

    final bus = await _firestore.getBusById(busId);
    if (!mounted) return;

    if (bus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No bus found for QR "$busId".')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BusProfileScreen(bus: bus)),
    );
  }

  void _openPlateLookup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlateLookupScreen()),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature module coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8), // Soft Mint-White surface
      body: SafeArea(
        child: _selectedTab == 3 ? _buildAccountTab() : _buildHomeTab(),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Greeting Header (matches reference top bar)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B2E26).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2E26),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B2E26),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => _showComingSoon('Speed Alerts'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Hero Emerald Safety Card (replaces orange "Current Delivery" card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F6E5C),
                  Color(0xFF0B2E26),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2E26).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bus Safety Check',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Live Ready',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check Your Bus\nBefore You Board',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Lookup + QR Scan action row
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B2E26),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onPressed: _openPlateLookup,
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: const Text(
                          'Enter Plate No.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _openQrScanner,
                      child: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Quick Services Row (4 rounded icons like the video)
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B2E26),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ServiceItem(
                icon: Icons.directions_bus_rounded,
                label: 'Plate Lookup',
                onTap: _openPlateLookup,
              ),
              _ServiceItem(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR',
                onTap: _openQrScanner,
              ),
              _ServiceItem(
                icon: Icons.speed_rounded,
                label: 'Live Speed',
                onTap: () => _showComingSoon('Live Speed'),
              ),
              _ServiceItem(
                icon: Icons.report_gmailerrorred_rounded,
                label: 'Report',
                onTap: () => _showComingSoon('Report Incident'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Quick Demo Bus Card (replaces "Active Shipments")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Check',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B2E26),
                ),
              ),
              TextButton(
                onPressed: _openPlateLookup,
                child: const Text(
                  'Search All',
                  style: TextStyle(
                    color: Color(0xFF1F6E5C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2E26).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF1F6E5C),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Malaysian Buses',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B2E26),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Search by plate number or scan the QR inside the bus to see live safety ratings.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE6F7F1),
            child: const Icon(
              Icons.person_rounded,
              size: 38,
              color: Color(0xFF0B2E26),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B2E26),
            ),
          ),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Spacer(),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              await _auth.logout();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Floating rounded bottom nav bar (inspired by the reference video)
  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2E26).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Lookup',
            active: false,
            onTap: _openPlateLookup,
          ),
          _NavItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            active: false,
            onTap: _openQrScanner,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Account',
            active: _selectedTab == 3,
            onTap: () => setState(() => _selectedTab = 3),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2E26).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1F6E5C), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B2E26),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1F6E5C) : Colors.grey.shade500;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
