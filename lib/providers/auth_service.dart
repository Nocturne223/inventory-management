import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update last login time
        await _updateLastLogin(credential.user!.uid);

        // Get user data from Firestore
        return await getUserData(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // Register with email and password
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final appUser = AppUser(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toMap());

        return appUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Update last login time
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create admin user (for initial setup)
  Future<AppUser?> createAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    return await registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: 'admin',
    );
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges.asyncMap((user) async {
    if (user == null) {
      return AuthUnauthenticated();
    } else {
      try {
        final appUser = await authService.getUserData(user.uid);
        if (appUser != null) {
          return AuthAuthenticated(appUser);
        } else {
          return AuthUnauthenticated();
        }
      } catch (e) {
        return AuthError('Error loading user data: $e');
      }
    }
  });
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state is AuthAuthenticated ? state.user : null,
    loading: () => null,
    error: (_, __) => null,
  );
});
