import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import '../lookup/bus_profile_screen.dart';
import '../lookup/plate_lookup_screen.dart';

/// Live horizontal "Quick Check" carousel showing real buses & safety ratings.
class QuickCheckSection extends StatelessWidget {
  const QuickCheckSection({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header + "See All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Check',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B2E26),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap any bus for live safety details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F7A72),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlateLookupScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1F6E5C),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Search all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Live Firestore Stream of Buses
        SizedBox(
          height: 176,
          child: StreamBuilder<List<Bus>>(
            stream: firestore.streamBuses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, __) => const _SkeletonBusCard(),
                );
              }

              final buses = snapshot.data ?? [];
              if (buses.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF0B2E26).withValues(alpha: 0.06),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          color: Color(0xFF1F6E5C),
                          size: 28,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'No buses listed yet. Use Plate Lookup or QR Scan to check any bus.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5F7A72),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: buses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _LiveBusCard(
                    bus: buses[index],
                    firestore: firestore,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual Bento-style bus card with live rating pill & progress bar.
class _LiveBusCard extends StatelessWidget {
  final Bus bus;
  final FirestoreService firestore;

  const _LiveBusCard({
    required this.bus,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Rating?>(
      stream: firestore.streamRating(bus.id),
      builder: (context, ratingSnap) {
        final score = ratingSnap.data?.score;
        final _RiskStyle risk = _RiskStyle.fromScore(score);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BusProfileScreen(bus: bus)),
              );
            },
            child: Ink(
              width: 264,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: risk.accent.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B2E26).withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Malaysian Plate Badge + Live Traffic-Light Score Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2E26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bus.plateNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: risk.bg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: risk.accent,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              score != null
                                  ? '${score.toStringAsFixed(0)} • ${risk.label}'
                                  : 'No Rating',
                              style: TextStyle(
                                color: risk.text,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Operator Name
                  Text(
                    bus.operatorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B2E26),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Route with subtle icon
                  Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        size: 14,
                        color: Color(0xFF1F6E5C),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          bus.route,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F7A72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Micro Safety Progress Bar + Tap Affordance
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: ((score ?? 0) / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEEF2F1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(risk.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7F1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Color(0xFF1F6E5C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Clean placeholder card shown while Firestore streams initial buses.
class _SkeletonBusCard extends StatelessWidget {
  const _SkeletonBusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 160,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F4),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F4),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskStyle {
  final Color accent;
  final Color bg;
  final Color text;
  final String label;

  const _RiskStyle({
    required this.accent,
    required this.bg,
    required this.text,
    required this.label,
  });

  factory _RiskStyle.fromScore(double? score) {
    if (score == null) {
      return const _RiskStyle(
        accent: Color(0xFF94A3B8),
        bg: Color(0xFFF1F5F9),
        text: Color(0xFF475569),
        label: 'Unrated',
      );
    }
    if (score >= 80) {
      return const _RiskStyle(
        accent: Color(0xFF10B981),
        bg: Color(0xFFD1FAE5),
        text: Color(0xFF065F46),
        label: 'Safe',
      );
    }
    if (score >= 60) {
      return const _RiskStyle(
        accent: Color(0xFFF59E0B),
        bg: Color(0xFFFEF3C7),
        text: Color(0xFF92400E),
        label: 'Caution',
      );
    }
    return const _RiskStyle(
      accent: Color(0xFFEF4444),
      bg: Color(0xFFFEE2E2),
      text: Color(0xFF991B1B),
      label: 'High Risk',
    );
  }
}
