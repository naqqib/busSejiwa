import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

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
      body: Center(child: Text('Home (logged in)')),
    );
  }
}