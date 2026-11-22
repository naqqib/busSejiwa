import 'package:flutter/material.dart';
import 'bus_profile_screen.dart';
import '../../core/services/firestore_service.dart';

class PlateLookupScreen extends StatefulWidget {
  const PlateLookupScreen({super.key});

  @override
  State<PlateLookupScreen> createState() => _PlateLookupScreenState();
}

class _PlateLookupScreenState extends State<PlateLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _db = FirestoreService();
  bool _loading = false;

  @override
  void dispose() {
    // Release the controller when this screen closes.
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Use the shared service to search by the entered plate.
      final bus = await _db.getBusByPlate(_plateController.text);

      // The user may have closed this screen while waiting.
      if (!mounted) return;

      // Report a missing bus and stop this search.
      if (bus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus not found.')),
        );
        return;
      }

      // Open the profile and pass the bus found by Firestore.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BusProfileScreen(bus: bus),
        ),
      );
    } catch (e) {
      // Keep the technical error in the development console.
      debugPrint('Plate lookup failed: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to search. Please try again.')),
      );
    } finally {
      // Restore the button if this screen still exists.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Bus')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Bus plate number',
                  hintText: 'PDE 1234',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  // Reject empty input and input containing only spaces.
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bus plate number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _search,
                child: Text(_loading ? 'Searching...' : 'Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
