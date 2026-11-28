import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'firestore_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = AppUser(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    await _db.createUserProfile(user);
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static bool _googleInitialized = false;

  /// Signs in with Google using the native small account-picker popup on mobile.
  /// Returns `true` if this is a brand-new user (so the UI can show Onboarding).
  Future<bool> signInWithGoogle() async {
    final UserCredential credential;

    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      // Initialize GoogleSignIn once before calling authenticate()
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }

      final googleUser = await GoogleSignIn.instance.authenticate();

      // Build a Firebase credential from Google's ID token
      final authCredential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      credential = await _auth.signInWithCredential(authCredential);
    }

    final user = credential.user;
    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

    // Create Firestore profile if this is their first time
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'name': user.displayName ?? 'Passenger',
          'email': user.email ?? '',
          'role': 'passenger',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return isNewUser;
  }

  Future<void> logout() => _auth.signOut();
}
