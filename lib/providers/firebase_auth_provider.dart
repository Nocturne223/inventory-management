import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/app_user.dart';

// Firebase Auth Service
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time in Firestore
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get AppUser from Firestore
  Future<AppUser?> getAppUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      print('Error getting app user: $e');
      return null;
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set(
          {
            'lastLoginAt': DateTime.now().toIso8601String(),
          },
          SetOptions(
              merge: true)); // Use merge to avoid overwriting existing data
    } catch (e) {
      print('Error updating last login: $e');
      // Don't throw error here, as this is not critical for auth flow
    }
  }

  // Create user document in Firestore (for new users)
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    String role = 'Tech', // Default role
  }) async {
    try {
      final appUser = AppUser(
        id: uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );

      await _firestore.collection('users').doc(uid).set(appUser.toMap());
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user profile');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

// Providers
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Current AppUser provider
final currentAppUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final authService = ref.watch(firebaseAuthServiceProvider);

  yield* authState.when(
    data: (user) async* {
      if (user != null) {
        final appUser = await authService.getAppUser(user.uid);
        yield appUser;
      } else {
        yield null;
      }
    },
    loading: () async* {
      yield null;
    },
    error: (error, stack) async* {
      print('Auth state error: $error');
      yield null;
    },
  );
});

// Current user provider (for compatibility)
final currentUserProvider = currentAppUserProvider;

// Auth state notifier for UI state management
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;

  AuthNotifier(this._authService) : super(AuthInitial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = AuthLoading();

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        final appUser = await _authService.getAppUser(credential!.user!.uid);
        if (appUser != null) {
          state = AuthAuthenticated(appUser);
        } else {
          state = AuthError(
              'User profile not found. Please contact administrator.');
        }
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthUnauthenticated();
    } catch (e) {
      state = AuthError('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void reset() {
    state = AuthInitial();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return AuthNotifier(authService);
});
