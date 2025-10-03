// Standalone seeding script for 10 users
// This script can be run independently from Flutter
import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔥 User Seeding Script for MIT Inventory Management System');
  print('📝 Creating 10 diverse users for testing...');
  print('');

  // User data to be added to Firestore
  final users = [
    // 1. SuperAdmin User
    {
      'uid': 'superadmin_001',
      'email': 'emma.superadmin@mit.edu',
      'firstName': 'Emma',
      'lastName': 'SuperAdmin',
      'displayName': 'Emma SuperAdmin',
      'role': 'superAdmin',
      'department': 'IT Department',
      'phoneNumber': '+1-555-0101',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(hours: 2)).millisecondsSinceEpoch,
      'twoFactorEnabled': true,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'delete_component': true,
        'view_analytics': true,
        'manage_users': true,
        'manage_system': true,
        'manage_data': true,
        'manage_laboratories': true,
        'create_deployment': true,
        'manage_maintenance': true,
        'generate_reports': true,
        'system_configuration': true,
        'backup_restore': true,
      },
    },

    // 2. Primary Admin User
    {
      'uid': 'admin_001',
      'email': 'john.admin@mit.edu',
      'firstName': 'John',
      'lastName': 'Administrator',
      'displayName': 'John Administrator',
      'role': 'admin',
      'department': 'IT Department',
      'phoneNumber': '+1-555-0102',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(hours: 6)).millisecondsSinceEpoch,
      'twoFactorEnabled': true,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'delete_component': true,
        'view_analytics': true,
        'manage_users': true,
        'manage_laboratories': true,
        'create_deployment': true,
        'manage_maintenance': true,
        'generate_reports': true,
      },
    },

    // 3. Secondary Admin User
    {
      'uid': 'admin_002',
      'email': 'robert.admin@mit.edu',
      'firstName': 'Robert',
      'lastName': 'Davis',
      'displayName': 'Robert Davis',
      'role': 'admin',
      'department': 'System Administration',
      'phoneNumber': '+1-555-0109',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 45)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
      'twoFactorEnabled': true,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'delete_component': true,
        'view_analytics': true,
        'manage_users': true,
        'manage_laboratories': true,
        'create_deployment': true,
        'manage_maintenance': true,
        'generate_reports': true,
      },
    },

    // 4. Engineering Manager
    {
      'uid': 'manager_001',
      'email': 'sarah.manager@mit.edu',
      'firstName': 'Sarah',
      'lastName': 'Johnson',
      'displayName': 'Sarah Johnson',
      'role': 'manager',
      'department': 'Engineering Department',
      'phoneNumber': '+1-555-0103',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(hours: 4)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'view_analytics': true,
        'manage_laboratories': true,
        'create_deployment': true,
        'manage_maintenance': true,
        'generate_reports': true,
      },
    },

    // 5. Research Manager
    {
      'uid': 'manager_002',
      'email': 'maria.manager@mit.edu',
      'firstName': 'Maria',
      'lastName': 'Rodriguez',
      'displayName': 'Maria Rodriguez',
      'role': 'manager',
      'department': 'Research Department',
      'phoneNumber': '+1-555-0108',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 20)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(hours: 8)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'view_analytics': true,
        'manage_laboratories': true,
        'create_deployment': true,
        'manage_maintenance': true,
        'generate_reports': true,
      },
    },

    // 6. Technical Support Technician
    {
      'uid': 'technician_001',
      'email': 'mike.tech@mit.edu',
      'firstName': 'Mike',
      'lastName': 'Thompson',
      'displayName': 'Mike Thompson',
      'role': 'technician',
      'department': 'Technical Support',
      'phoneNumber': '+1-555-0104',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 90)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(hours: 12)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'create_deployment': true,
        'manage_maintenance': true,
      },
    },

    // 7. Hardware Maintenance Technician
    {
      'uid': 'technician_002',
      'email': 'lisa.tech@mit.edu',
      'firstName': 'Lisa',
      'lastName': 'Chen',
      'displayName': 'Lisa Chen',
      'role': 'technician',
      'department': 'Hardware Maintenance',
      'phoneNumber': '+1-555-0105',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 75)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(days: 2)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'create_deployment': true,
        'manage_maintenance': true,
      },
    },

    // 8. Computer Science User
    {
      'uid': 'user_001',
      'email': 'jane.user@mit.edu',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'displayName': 'Jane Smith',
      'role': 'user',
      'department': 'Computer Science',
      'phoneNumber': '+1-555-0106',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 120)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(days: 3)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'view_components': true,
      },
    },

    // 9. Mathematics User
    {
      'uid': 'user_002',
      'email': 'david.user@mit.edu',
      'firstName': 'David',
      'lastName': 'Wilson',
      'displayName': 'David Wilson',
      'role': 'user',
      'department': 'Mathematics',
      'phoneNumber': '+1-555-0107',
      'profileImageUrl': null,
      'isActive': true,
      'createdAt':
          DateTime.now().subtract(Duration(days: 100)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(days: 5)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'view_components': true,
      },
    },

    // 10. Test Inactive User
    {
      'uid': 'user_inactive_001',
      'email': 'inactive.user@mit.edu',
      'firstName': 'Inactive',
      'lastName': 'User',
      'displayName': 'Inactive User',
      'role': 'user',
      'department': 'Test Department',
      'phoneNumber': '+1-555-0110',
      'profileImageUrl': null,
      'isActive': false,
      'createdAt':
          DateTime.now().subtract(Duration(days: 365)).millisecondsSinceEpoch,
      'lastLogin':
          DateTime.now().subtract(Duration(days: 180)).millisecondsSinceEpoch,
      'twoFactorEnabled': false,
      'permissions': {
        'view_components': true,
      },
    },
  ];

  print('👥 User Data Generated:');
  print('');

  int index = 1;
  for (final user in users) {
    print('$index. ${user['displayName']} (${user['email']})');
    print('   Role: ${user['role']}');
    print('   Department: ${user['department']}');
    print('   Status: ${(user['isActive'] as bool) ? 'Active' : 'Inactive'}');
    print(
        '   2FA: ${(user['twoFactorEnabled'] as bool) ? 'Enabled' : 'Disabled'}');
    print('   Permissions: ${(user['permissions'] as Map).length} permissions');
    print('');
    index++;
  }

  // Generate JSON output for manual import
  final output = {
    'users': users,
    'metadata': {
      'totalUsers': users.length,
      'generatedAt': DateTime.now().toIso8601String(),
      'script': 'standalone_seed_users.dart',
      'description': 'MIT Inventory Management System - Test Users'
    }
  };

  // Save to JSON file
  final file = File('seeded_users.json');
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(output));

  print('📄 User data saved to: seeded_users.json');
  print('');
  print('📋 Summary:');
  print('   • SuperAdmin: 1 user (emma.superadmin@mit.edu)');
  print('   • Admin: 2 users (john.admin@mit.edu, robert.admin@mit.edu)');
  print('   • Manager: 2 users (sarah.manager@mit.edu, maria.manager@mit.edu)');
  print('   • Technician: 2 users (mike.tech@mit.edu, lisa.tech@mit.edu)');
  print('   • User: 2 users (jane.user@mit.edu, david.user@mit.edu)');
  print('   • Inactive: 1 user (inactive.user@mit.edu)');
  print('');
  print('🔐 Manual Import Instructions:');
  print('1. Go to Firebase Console → Firestore Database');
  print('2. Import the generated JSON data into the "users" collection');
  print('3. Create Firebase Authentication accounts for each email');
  print('4. Match the UIDs when creating auth accounts');
  print('');
  print('✅ User seeding completed successfully!');
}
