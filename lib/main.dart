import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BusSejiwaApp());
}

class BusSejiwaApp extends StatelessWidget {
  const BusSejiwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BusSejiwa',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
    
  }
}