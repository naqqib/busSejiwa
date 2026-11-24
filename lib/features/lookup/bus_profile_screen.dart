import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';

/// Displays the details of a bus found by lookup.
class BusProfileScreen extends StatelessWidget {
  // Opening this screen requires a Bus object.
  const BusProfileScreen({super.key, required this.bus});

  // Holds the bus passed from the search screen.
  final Bus bus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Profile')),
      // ListView lets the details scroll when needed.
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            title: const Text('Plate number'),
            subtitle: Text(bus.plateNumber),
          ),
          ListTile(
            title: const Text('Operator'),
            subtitle: Text(bus.operatorName),
          ),
          ListTile(title: const Text('Route'), subtitle: Text(bus.route)),
          ListTile(title: const Text('Model'), subtitle: Text(bus.model)),
          const SizedBox(height: 16),
          _buildRatingSection(bus.id),
          const SizedBox(height: 16),
          _buildViolationsSection(bus.id),
        ],
      ),
    );
  }

  Widget _buildRatingSection(String busId) {
    return StreamBuilder<Rating?>(
      stream: FirestoreService().streamRating(busId),
      builder: (context, snapshot) {
        // State 1: Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // State 2: Error
        if (snapshot.hasError) {
          return Text('Failed to load rating: ${snapshot.error}');
        }

        // State 3: No rating document in Firestore yet
        final rating = snapshot.data;
        if (rating == null) {
          return const Text('No rating available yet');
        }

        // State 4: Rating is available
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety Rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${rating.score.toStringAsFixed(1)} / 100'),
                if (rating.isProvisional)
                  Text(
                    'Provisional (based on ${rating.tripsCounted} of ${Rating.minTripsForRating} trips)',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${rating.violationsLast30Days} speeding events logged in the last 30 days',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViolationsSection(String busId) {
    return FutureBuilder<List<Violation>>( 
      future: FirestoreService().getViolationsForBus(busId, limit: 5),
      builder: (context, snapshot) {
        // State 1: Loading
        if (snapshot.connectionState == ConnectionState.waiting) { // TODO 3: Waiting state
          return const Center(child: CircularProgressIndicator());
        }

        // State 2: Error
        if (snapshot.hasError) { // TODO 4: Check if snapshot has an error
          return Text('Failed to load violations: ${snapshot.error}');
        }

        // State 3: Empty list
        final violations = snapshot.data ?? [];
        if (violations.isEmpty) { // TODO 5: Check if violations list is empty
          return const Text('No recent violations recorded');
        }

        // State 4: Show the list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Violations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...violations.map(
              (v) => ListTile(
                // TODO 6: Show recorded speed and speed limit (e.g. "112 km/h (limit 90 km/h)")
                title: Text(
                  '${v.speedKmh.toStringAsFixed(0)} km/h (limit ${v.limitKmh.toStringAsFixed(0)} km/h)',
                ),
                // TODO 7: Show roadName (fallback to 'Unknown road' if null) and severity name
                subtitle: Text(
                  '${v.roadName ?? 'Unknown road'} • ${v.severity.name}',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
