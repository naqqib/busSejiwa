import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import 'register_screen.dart';

/// Login screen for passengers, operators and admins.
///
/// After a successful login there is no manual navigation:
/// [AuthGate] listens to the auth state and switches to HomeScreen
/// automatically.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Lets us validate all fields of the form at once.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Created once per screen, not inside build(), so it isn't
  // recreated on every rebuild.
  final _auth = AuthService();

  // True while waiting for Firebase; disables the button and shows a spinner.
  bool _loading = false;

  @override
  void dispose() {
    // Controllers hold resources, so free them when the screen closes.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Run every field's validator; stop before contacting Firebase if any fail.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return; // Screen may have closed during the await.
      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first screen (AuthGate)
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes into user-friendly messages.
      // 'invalid-credential' is deliberately vague (doesn't say whether the
      // email or password was wrong) to prevent user enumeration.
      String message;
      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password.';
        case 'invalid-email':
          message = 'That email address is not valid.';
        case 'too-many-requests':
          // Firebase's brute-force protection after repeated failed attempts.
          message = 'Too many login attempts. Please try again later.';
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      // The screen may have closed during the await; using context then
      // would throw an error.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      // Always stop the spinner, whether login succeeded or failed.
      // On success this screen is replaced by HomeScreen, so check mounted.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BusSejiwa Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // Basic format check only; Firebase does the full validation.
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email.';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email.';
                  }
                  return null; // null = valid
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                // No length check here: the account already exists, and the
                // 6-character minimum is enforced on the register screen.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // A null onPressed disables the button, preventing
                  // double-taps while a login request is in progress.
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
              TextButton(
                // Prevent navigation while a login request is running.
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: const Text('No account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}