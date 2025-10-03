import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // List of users to seed
  final users = [
    // Existing authenticated user
    {
      'uid': 'APduHk4yn8TL1W9oahqYI0w4efU2',
      'email': 'admin@mit.edu',
      'name': 'System Administrator',
      'role': 'Admin',
      'isActive': true
    },
    // Tech role users
    {
      'uid': 'tech_user_001',
      'email': 'tech1@mit.edu',
      'name': 'Technical Support 1',
      'role': 'Tech',
      'isActive': true
    },
    {
      'uid': 'tech_user_002',
      'email': 'tech2@mit.edu',
      'name': 'Technical Support 2',
      'role': 'Tech',
      'isActive': true
    },
    // GSO role users
    {
      'uid': 'gso_user_001',
      'email': 'gso1@mit.edu',
      'name': 'General Services Officer 1',
      'role': 'GSO',
      'isActive': true
    },
    {
      'uid': 'gso_user_002',
      'email': 'gso2@mit.edu',
      'name': 'General Services Officer 2',
      'role': 'GSO',
      'isActive': true
    },
    // MIS role user
    {
      'uid': 'mis_user_001',
      'email': 'mis@mit.edu',
      'name': 'Management Information Systems',
      'role': 'MIS',
      'isActive': true
    },
    // Admin role users
    {
      'uid': 'admin_user_002',
      'email': 'admin2@mit.edu',
      'name': 'Department Administrator',
      'role': 'Admin',
      'isActive': true
    },
    // SuperAdmin role user
    {
      'uid': 'superadmin_user_001',
      'email': 'superadmin@mit.edu',
      'name': 'Super Administrator',
      'role': 'SuperAdmin',
      'isActive': true
    },
    // Inactive user for testing
    {
      'uid': 'inactive_user_001',
      'email': 'inactive@mit.edu',
      'name': 'Inactive User',
      'role': 'Tech',
      'isActive': false
    }
  ];

  print('🔥 Seeding users with different roles to Firestore...');
  print('📝 Seeding ${users.length} users...');

  final now = DateTime.now().toIso8601String();

  for (final user in users) {
    try {
      final userData = {
        'email': user['email'],
        'name': user['name'],
        'role': user['role'],
        'createdAt': now,
        'lastLoginAt':
            user['uid'] == 'APduHk4yn8TL1W9oahqYI0w4efU2' ? now : null,
        'isActive': user['isActive']
      };

      await firestore
          .collection('users')
          .doc(user['uid'] as String)
          .set(userData);
      print('✅ Successfully seeded user: ${user['email']} (${user['role']})');
    } catch (error) {
      print('❌ Failed to seed user ${user['uid']}: $error');
    }
  }

  // Print summary
  final roleCounts = <String, int>{};
  for (final user in users) {
    final role = user['role'] as String;
    roleCounts[role] = (roleCounts[role] ?? 0) + 1;
  }

  print('\n📊 User roles summary:');
  roleCounts.forEach((role, count) {
    print('   $role: $count users');
  });

  print('✅ User seeding completed!');
}
