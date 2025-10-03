import 'dart:convert';
import 'package:http/http.dart' as http;

// Script to seed users with different roles to Firestore users collection
void main() async {
  print('🔥 Seeding users with different roles to Firestore...');

  const projectId = 'inventory-management-aefea'; // From your Firebase project

  try {
    await seedUsers(projectId);
    print('✅ All users seeded successfully!');
  } catch (e) {
    print('❌ Error seeding users: $e');
  }
}

Future<void> seedUsers(String projectId) async {
  // Define users with different roles based on your requirements
  final users = [
    {
      // Existing admin user - just ensure it's properly formatted
      'docId': 'APduHk4yn8TL1W9oahqYI0w4efU2', // Existing Firebase Auth UID
      'data': {
        'fields': {
          'email': {'stringValue': 'admin@mit.edu'},
          'name': {'stringValue': 'Albert James'},
          'role': {'stringValue': 'Admin'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {'stringValue': DateTime.now().toIso8601String()},
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // Tech role user
      'docId': 'tech_user_001',
      'data': {
        'fields': {
          'email': {'stringValue': 'tech@mit.edu'},
          'name': {'stringValue': 'Sarah Tech'},
          'role': {'stringValue': 'Tech'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // GSO role user
      'docId': 'gso_user_001',
      'data': {
        'fields': {
          'email': {'stringValue': 'gso@mit.edu'},
          'name': {'stringValue': 'Mike GSO'},
          'role': {'stringValue': 'GSO'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(hours: 5))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // MIS role user
      'docId': 'mis_user_001',
      'data': {
        'fields': {
          'email': {'stringValue': 'mis@mit.edu'},
          'name': {'stringValue': 'Lisa MIS'},
          'role': {'stringValue': 'MIS'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // Additional Admin user
      'docId': 'admin_user_002',
      'data': {
        'fields': {
          'email': {'stringValue': 'admin2@mit.edu'},
          'name': {'stringValue': 'John Admin'},
          'role': {'stringValue': 'Admin'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(minutes: 30))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // SuperAdmin role user
      'docId': 'superadmin_user_001',
      'data': {
        'fields': {
          'email': {'stringValue': 'superadmin@mit.edu'},
          'name': {'stringValue': 'Emma SuperAdmin'},
          'role': {'stringValue': 'SuperAdmin'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(minutes: 10))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // Additional Tech users
      'docId': 'tech_user_002',
      'data': {
        'fields': {
          'email': {'stringValue': 'tech2@mit.edu'},
          'name': {'stringValue': 'David Tech'},
          'role': {'stringValue': 'Tech'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(hours: 3))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // Additional GSO user
      'docId': 'gso_user_002',
      'data': {
        'fields': {
          'email': {'stringValue': 'gso2@mit.edu'},
          'name': {'stringValue': 'Rachel GSO'},
          'role': {'stringValue': 'GSO'},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(hours: 4))
                .toIso8601String()
          },
          'isActive': {'booleanValue': true},
        }
      }
    },
    {
      // Inactive user for testing
      'docId': 'inactive_user_001',
      'data': {
        'fields': {
          'email': {'stringValue': 'inactive@mit.edu'},
          'name': {'stringValue': 'Tom Inactive'},
          'role': {'stringValue': 'Tech'},
          'createdAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String()
          },
          'lastLoginAt': {
            'stringValue': DateTime.now()
                .subtract(const Duration(days: 15))
                .toIso8601String()
          },
          'isActive': {'booleanValue': false},
        }
      }
    }
  ];

  print('📝 Seeding ${users.length} users...');

  for (final user in users) {
    final docId = user['docId'] as String;
    final userData = user['data'] as Map<String, dynamic>;

    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$docId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final name = userData['fields']['name']['stringValue'];
        final role = userData['fields']['role']['stringValue'];
        print('✅ User: $name ($role) seeded');
      } else {
        print('❌ Failed to seed user $docId: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error seeding user $docId: $e');
    }

    // Small delay to avoid rate limiting
    await Future.delayed(const Duration(milliseconds: 200));
  }

  print('\n📊 User roles summary:');
  final roleCount = <String, int>{};
  for (final user in users) {
    final userData = user['data'] as Map<String, dynamic>;
    final role = userData['fields']['role']['stringValue'] as String;
    roleCount[role] = (roleCount[role] ?? 0) + 1;
  }

  roleCount.forEach((role, count) {
    print('   $role: $count users');
  });
}
