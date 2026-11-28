import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/seed_data_service.dart';
import '../../core/utils/app_transitions.dart';
import '../auth/onboarding_screen.dart';
import '../lookup/bus_profile_screen.dart';
import '../lookup/bus_search_overlay.dart';
import '../lookup/plate_lookup_screen.dart';
import '../lookup/qr_scan_screen.dart';
import 'quick_check_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  int _selectedTab = 0;
  bool _searching = false;

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

    setState(() => _searching = true);
    try {
      final busFuture = _firestore.getBusById(busId);
      await Future.delayed(const Duration(milliseconds: 900));
      final bus = await busFuture;
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
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _openPlateLookup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlateLookupScreen()),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature module coming soon!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8), // Soft Mint-White surface
      body: Stack(
        children: [
          SafeArea(
            top: _selectedTab != 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedTab),
                child: _selectedTab == 3 ? _buildAccountTab() : _buildHomeTab(),
              ),
            ),
          ),
          if (_searching)
            const BusSearchOverlay(message: 'Searching your bus...'),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting Header
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
                            color: const Color(0xFF0B2E26)
                                .withValues(alpha: 0.08),
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

                // 2. Hero Emerald Safety Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F6E5C), Color(0xFF0B2E26)],
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
                              color: const Color(0xFF6EE7B7)
                                  .withValues(alpha: 0.2),
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
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0B2E26),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
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
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Quick Services Row
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
              ],
            ),
          ),

          const SizedBox(height: 26),

          // 4. Live Edge-to-Edge Quick Check Carousel
          const QuickCheckSection(),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<AppUser?>(
      future: user != null ? _firestore.getUser(user.uid) : null,
      builder: (context, snapshot) {
        final appUser = snapshot.data;
        final roleName = appUser?.role.name ?? 'passenger';
        final roleLabel =
            '${roleName[0].toUpperCase()}${roleName.substring(1)}';
        final isAdmin = roleName == 'admin';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Curved Dark Emerald Profile Header (bleeds smoothly behind status bar)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F6E5C), Color(0xFF0B2E26)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Avatar with Mint Ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6EE7B7),
                            width: 2.2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFE6F7F1),
                          child: Icon(
                            Icons.person_rounded,
                            size: 38,
                            color: Color(0xFF0B2E26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        _displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'BusSejiwa $roleLabel',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Translucent 3-Column Stats Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AccountStat(value: roleLabel, label: 'Role'),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white24,
                            ),
                            const _AccountStat(value: 'Active', label: 'Status'),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white24,
                            ),
                            const _AccountStat(value: 'MY', label: 'Region'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Personal Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Personal Info',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2E26),
                      ),
                    ),
                    const SizedBox(height: 12),

                    StaggeredEntrance(
                      index: 0,
                      child: _ProfileInfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: _displayName,
                      ),
                    ),
                    const SizedBox(height: 10),

                    StaggeredEntrance(
                      index: 1,
                      child: _ProfileInfoTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: user?.email ?? 'Not provided',
                      ),
                    ),
                    const SizedBox(height: 10),

                    StaggeredEntrance(
                      index: 2,
                      child: _ProfileInfoTile(
                        icon: Icons.verified_user_outlined,
                        label: 'Account Role',
                        value: roleLabel,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 3. App Actions Section
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2E26),
                      ),
                    ),
                    const SizedBox(height: 12),

                    StaggeredEntrance(
                      index: 3,
                      child: TactileTap(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OnboardingScreen(),
                            ),
                          );
                        },
                        child: const _ProfileInfoTile(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'App Walkthrough',
                          value: 'Replay App Tutorial',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF1F6E5C),
                          ),
                        ),
                      ),
                    ),

                    // Admin-only Dev Seeder
                    if (kDebugMode && isAdmin) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1F6E5C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () async {
                          try {
                            await SeedDataService().seedDemoData();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Seeded 3 demo buses (WXY 1234, PNQ 5678, JDT 9012)!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Seed failed: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.dataset_rounded),
                        label: const Text(
                          'Seed Demo Buses (Dev)',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Sign Out Button
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Floating rounded bottom nav bar
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
    return TactileTap(
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
    return TactileTap(
      onTap: onTap,
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

class _AccountStat extends StatelessWidget {
  final String value;
  final String label;

  const _AccountStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1F6E5C), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B2E26),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
