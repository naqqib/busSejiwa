import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

/// Registration screen for new passenger accounts.
///
/// AuthService creates the Firebase account and Firestore passenger profile.
/// Registration also signs the user in, so AuthGate displays HomeScreen
/// underneath this pushed route. This screen then closes itself on success.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Connects to the Form so _submit() can validate every field at once.
  final _formKey = GlobalKey<FormState>();

  // Controllers let us read the text entered into each field.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keep one service instance for this screen's state across rebuilds.
  final _auth = AuthService();

  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Disables Register and shows a spinner while registration is running.
  bool _loading = false;

  @override
  void dispose() {
    // Release all controllers when Flutter removes this screen.
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Stop here if any field is invalid, before sending a Firebase request.
    if (!_formKey.currentState!.validate()) return;

    // Rebuild the button to show that registration is in progress.
    setState(() => _loading = true);

    try {
      // Pass the entered values to our shared registration service.
      await _auth.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Stop if this widget was removed while we were waiting.
      if (!mounted) return;

      // Close this pushed route to reveal the screen managed by AuthGate.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Turn Firebase Authentication error codes into readable messages.
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
        case 'weak-password':
          message = 'Please choose a stronger password.';
        case 'invalid-email':
          message = 'That email address is not valid.';
        case 'too-many-requests':
          // Firebase may temporarily block repeated requests.
          message = 'Too many attempts. Please try again later.';
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      // Only use context to show the message if this widget still exists.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      // Runs after success or failure; only rebuild if still mounted.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        // The key gives _submit() access to this Form's validation state.
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Collect the name that will be saved in the user profile.
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  // trim() makes a name containing only spaces invalid.
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null; // No error message means the field is valid.
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // This is a basic check; Firebase also validates the address.
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email.';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                // Hide the password as the user types.
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  // Check the registration form's minimum password length.
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  // Compare the entered text with the original password.
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // A null callback disables the button to prevent resubmitting.
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}