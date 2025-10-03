// Temporarily disabled Firebase auth provider for testing
// All Firebase-related authentication code is commented out

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/models/user.dart';

// Simple mock providers for testing without Firebase
final mockCurrentUserProvider = StateProvider<AppUser?>((ref) {
  return AppUser(
    id: 'test_user_1',
    email: 'admin@mit.edu',
    firstName: 'Test',
    lastName: 'Admin',
    displayName: 'Test Admin',
    role: UserRole.admin,
    department: 'IT Department',
    isActive: true,
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
    permissions: {
      'canManageUsers': true,
      'canManageComponents': true,
      'canManageLaboratories': true,
      'canManageDeployments': true,
      'canViewAnalytics': true,
    },
  );
});

// Mock provider for compatibility
final currentUserProvider = mockCurrentUserProvider;

// Mock auth service for testing
class MockAuthService {
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always return success for testing
  }

  Future<void> signOut() async {
    // Simulate sign out
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> resetPassword(String email) async {
    // Simulate password reset
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

final authServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});
