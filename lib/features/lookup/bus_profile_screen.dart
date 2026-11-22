import 'package:flutter/material.dart';
import '../../core/models/models.dart';

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
          ListTile(
            title: const Text('Route'),
            subtitle: Text(bus.route),
          ),
          ListTile(
            title: const Text('Model'),
            subtitle: Text(bus.model),
          ),
        ],
      ),
    );
  }
}