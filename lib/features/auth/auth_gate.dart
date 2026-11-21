import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // TODO A: still waiting → loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // TODO B: logged in → HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // TODO C: otherwise → LoginScreen
        return const LoginScreen();
      },
    );
  }
}