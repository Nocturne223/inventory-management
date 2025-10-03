import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  print('🔥 Starting User Seeding Process...');
  print('📝 Seeding 10 users with different roles to Firestore...');

  // List of 10 users with comprehensive details and different roles
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

    // 2. Admin User
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

    // 3. Manager User
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

    // 4. Technician User 1
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
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'create_deployment': true,
        'manage_maintenance': true,
      },
    },

    // 5. Technician User 2
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
      'permissions': {
        'create_component': true,
        'edit_component': true,
        'create_deployment': true,
        'manage_maintenance': true,
      },
    },

    // 6. Regular User 1
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
      'permissions': {
        'view_components': true,
      },
    },

    // 7. Regular User 2
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
      'permissions': {
        'view_components': true,
      },
    },

    // 8. Manager User 2
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

    // 9. Admin User 2
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

    // 10. Inactive User (for testing)
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
      'permissions': {
        'view_components': true,
      },
    },
  ];

  print('📊 User Role Distribution:');
  final roleCount = <String, int>{};
  for (final user in users) {
    final role = user['role'] as String;
    roleCount[role] = (roleCount[role] ?? 0) + 1;
  }

  roleCount.forEach((role, count) {
    print('   • $role: $count user${count > 1 ? 's' : ''}');
  });
  print('');

  final now = DateTime.now();
  int successCount = 0;
  int errorCount = 0;

  for (int i = 0; i < users.length; i++) {
    final user = users[i];
    try {
      // Create user document with comprehensive data
      final userData = {
        'email': user['email'],
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'displayName': user['displayName'],
        'role': user['role'],
        'department': user['department'],
        'phoneNumber': user['phoneNumber'],
        'profileImageUrl': user['profileImageUrl'],
        'isActive': user['isActive'],
        'permissions': user['permissions'],
        'createdAt': now.toIso8601String(),
        'lastLoginAt': user['isActive'] == true
            ? now.subtract(Duration(days: i)).toIso8601String()
            : null,
        'updatedAt': now.toIso8601String(),
        // Additional metadata
        'loginCount': user['isActive'] == true ? (10 - i) : 0,
        'lastActivity': user['isActive'] == true
            ? now.subtract(Duration(hours: i + 1)).toIso8601String()
            : null,
        'accountType': 'firebase_auth',
        'emailVerified': true,
        'twoFactorEnabled':
            user['role'] == 'superAdmin' || user['role'] == 'admin',
      };

      // Add user to Firestore
      await firestore
          .collection('users')
          .doc(user['uid'] as String)
          .set(userData);

      successCount++;
      print(
          '✅ [${i + 1}/10] ${user['displayName']} (${user['role']}) - Created successfully');
    } catch (e) {
      errorCount++;
      print('❌ [${i + 1}/10] ${user['displayName']} - Error: $e');
    }
  }

  print('');
  print('🎉 User Seeding Completed!');
  print('✅ Successfully created: $successCount users');
  if (errorCount > 0) {
    print('❌ Failed to create: $errorCount users');
  }
  print('');
  print('📋 Summary of Created Users:');
  print('   • SuperAdmin: 1 user (emma.superadmin@mit.edu)');
  print('   • Admin: 2 users (john.admin@mit.edu, robert.admin@mit.edu)');
  print('   • Manager: 2 users (sarah.manager@mit.edu, maria.manager@mit.edu)');
  print('   • Technician: 2 users (mike.tech@mit.edu, lisa.tech@mit.edu)');
  print('   • User: 2 users (jane.user@mit.edu, david.user@mit.edu)');
  print('   • Inactive: 1 user (inactive.user@mit.edu)');
  print('');
  print('🔐 Authentication Notes:');
  print('   • Users are created in Firestore only (no Firebase Auth)');
  print('   • Use Firebase Console to create authentication accounts');
  print('   • Match UIDs when creating auth accounts');
  print('   • SuperAdmin and Admin users have 2FA enabled in metadata');
  print('');
  print('🚀 Ready for testing with diverse user roles!');
}
