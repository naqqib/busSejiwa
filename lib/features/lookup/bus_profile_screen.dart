import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/utils/app_transitions.dart';

import '../../core/services/firestore_service.dart';

/// Displays the details, live safety rating, and recent violations of a bus.
class BusProfileScreen extends StatelessWidget {
  const BusProfileScreen({super.key, required this.bus});

  final Bus bus;

  /// Picks a safety status color based on the 0–100 score.
  Color _scoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981); // Safe Emerald
    if (score >= 60) return const Color(0xFFF59E0B); // Caution Amber
    return const Color(0xFFEF4444); // High-Risk Red
  }

  String _scoreLabel(double score) {
    if (score >= 80) return 'Good Safety Record';
    if (score >= 60) return 'Moderate Risk';
    return 'Needs Caution';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8),
      body: Column(
        children: [
          // 1. Dark Emerald Safety Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F6E5C), Color(0xFF0B2E26)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stylized Malaysian Plate Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              bus.plateNumber,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Color(0xFF0B2E26),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bus.operatorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.route_rounded,
                                size: 15,
                                color: Color(0xFF6EE7B7),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  bus.route,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Scrollable Body: Live Rating + Bus Details + Recent Violations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                StaggeredEntrance(index: 0, child: _buildRatingSection(bus.id)),
                const SizedBox(height: 18),
                StaggeredEntrance(index: 1, child: _buildDetailsCard()),
                const SizedBox(height: 22),
                StaggeredEntrance(
                  index: 2,
                  child: _buildViolationsSection(bus.id),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2E26).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bus Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B2E26),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.business_rounded,
            label: 'Operator',
            value: bus.operatorName,
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.alt_route_rounded,
            label: 'Route',
            value: bus.route,
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.directions_bus_filled_rounded,
            label: 'Model',
            value: bus.model,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(String busId) {
    return StreamBuilder<Rating?>(
      stream: FirestoreService().streamRating(busId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _statusCard(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Color(0xFF1F6E5C)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _statusCard(
            child: Text(
              'Failed to load rating: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        final rating = snapshot.data;
        if (rating == null) {
          return _statusCard(
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF1F6E5C)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No safety rating available for this bus yet.',
                    style: TextStyle(color: Color(0xFF0B2E26)),
                  ),
                ),
              ],
            ),
          );
        }

        final accent = _scoreColor(rating.score);
        final progress = (rating.score / 100.0).clamp(0.0, 1.0);

        return _statusCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Safety Rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B2E26),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _scoreLabel(rating.score),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    rating.score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              if (rating.isProvisional) ...[
                const SizedBox(height: 10),
                Text(
                  'Provisional (based on ${rating.tripsCounted} of ${Rating.minTripsForRating} trips)',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${rating.violationsLast30Days} speeding events in the last 30 days',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViolationsSection(String busId) {
    return FutureBuilder<List<Violation>>(
      future: FirestoreService().getViolationsForBus(busId, limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF1F6E5C)),
            ),
          );
        }

        if (snapshot.hasError) {
          return _statusCard(
            child: Text(
              'Failed to load violations: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        final violations = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Violations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B2E26),
              ),
            ),
            const SizedBox(height: 10),
            if (violations.isEmpty)
              _statusCard(
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No recent violations recorded for this bus.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B2E26),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...violations.map(
                (v) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B2E26).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${v.speedKmh.toStringAsFixed(0)} km/h (limit ${v.limitKmh.toStringAsFixed(0)} km/h)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0B2E26),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${v.roadName ?? 'Unknown road'} • ${v.severity.name}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
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
        );
      },
    );
  }

  Widget _statusCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2E26).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1F6E5C)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B2E26),
            ),
          ),
        ),
      ],
    );
  }
}
