import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../home/home_screen.dart';
import 'welcome_screen.dart'; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const WelcomeScreen(); 
      },
    );
  }
}
