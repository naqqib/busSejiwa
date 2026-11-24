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
}
