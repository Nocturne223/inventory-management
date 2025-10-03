import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/app_user.dart';

/// Simple utility to create an admin user for initial setup
class AdminSetup {
  static const String defaultAdminEmail = 'admin@mit.edu';
  static const String defaultAdminPassword = 'MITAdmin123!';
  static const String defaultAdminName = 'MIT Admin';

  static Future<void> createDefaultAdmin() async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Check if admin already exists by trying to sign in
      try {
        await auth.signInWithEmailAndPassword(
            email: defaultAdminEmail, password: defaultAdminPassword);
        print('Admin user already exists');
        await auth.signOut(); // Sign out after checking
        return;
      } catch (e) {
        // Continue with creation if sign-in fails (user doesn't exist)
      }

      // Create admin user
      final credential = await auth.createUserWithEmailAndPassword(
        email: defaultAdminEmail,
        password: defaultAdminPassword,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final appUser = AppUser(
          id: credential.user!.uid,
          email: defaultAdminEmail,
          name: defaultAdminName,
          role: 'admin',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toMap());

        print('Admin user created successfully');
        print('Email: $defaultAdminEmail');
        print('Password: $defaultAdminPassword');
      }
    } catch (e) {
      print('Error creating admin user: $e');
      rethrow;
    }
  }

  static Future<void> setupFirestorePermissions() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Test write permission by creating a simple test document
      await firestore.collection('test').doc('connection').set({
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Firebase connection test'
      });

      print('Firestore permissions verified');

      // Clean up test document
      await firestore.collection('test').doc('connection').delete();
    } catch (e) {
      print('Firestore permission error: $e');
      throw Exception(
          'Firebase permissions not properly configured. Please check Firestore security rules.');
    }
  }
}
