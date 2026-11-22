import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../lookup/plate_lookup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusSejiwa'),
        actions: [
          TextButton(
            onPressed: () async {
              // Sign out; AuthGate will show the Login screen.
              await AuthService().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlateLookupScreen(),
              ),
            );
          },
          child: const Text('Find a Bus'),
        ),
      ),
    );
  }
}