// Temporary providers for testing without Firebase
import 'package:flutter_riverpod/legacy.dart';
import '../core/models/user.dart';

// Mock current user for testing
final mockUserProvider = StateProvider<AppUser?>((ref) {
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

// Mock components data
final mockComponentsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'comp_1',
      'name': 'Dell OptiPlex 7090',
      'category': 'Computer',
      'serialNumber': 'DELL001',
      'status': 'Active',
      'location': 'Lab A',
    },
    {
      'id': 'comp_2',
      'name': 'HP LaserJet Pro',
      'category': 'Printer',
      'serialNumber': 'HP001',
      'status': 'Maintenance',
      'location': 'Office',
    },
    {
      'id': 'comp_3',
      'name': 'Cisco Switch 2960',
      'category': 'Network',
      'serialNumber': 'CISCO001',
      'status': 'Active',
      'location': 'Server Room',
    },
  ];
});

// Mock laboratory data
final mockLaboratoriesProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'lab_1',
      'name': 'Computer Lab A',
      'capacity': 30,
      'components': 25,
      'status': 'Active',
    },
    {
      'id': 'lab_2',
      'name': 'Network Lab',
      'capacity': 20,
      'components': 18,
      'status': 'Active',
    },
    {
      'id': 'lab_3',
      'name': 'Server Room',
      'capacity': 50,
      'components': 45,
      'status': 'Maintenance',
    },
  ];
});
