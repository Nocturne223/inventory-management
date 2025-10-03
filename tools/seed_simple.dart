import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Simple script to seed test data using Firestore REST API
void main() async {
  if (kDebugMode) {
    print('🌱 Seeding test data to Firestore...');
  }

  const projectId = 'inventory-management-aefea'; // From the error message

  try {
    // Seed departments
    await seedDepartments(projectId);

    // Seed locations
    await seedLocations(projectId);

    // Seed inventory items
    await seedInventoryItems(projectId);

    // Create test user
    await seedTestUser(projectId);

    if (kDebugMode) {
      print('✅ Test data seeded successfully!');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error seeding data: $e');
    }
  }
}

Future<void> seedDepartments(String projectId) async {
  final departments = [
    {
      'fields': {
        'name': {'stringValue': 'Computer Science'},
        'description': {'stringValue': 'Computer Science Department'},
        'head': {'stringValue': 'Dr. Smith'},
        'contactEmail': {'stringValue': 'cs@mit.edu'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
      }
    },
    {
      'fields': {
        'name': {'stringValue': 'Electrical Engineering'},
        'description': {'stringValue': 'Electrical Engineering Department'},
        'head': {'stringValue': 'Dr. Johnson'},
        'contactEmail': {'stringValue': 'ee@mit.edu'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
      }
    },
  ];

  for (int i = 0; i < departments.length; i++) {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/departments/dept-$i';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(departments[i]),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Department ${i + 1} seeded');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to seed department ${i + 1}: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seeding department ${i + 1}: $e');
      }
    }
  }
}

Future<void> seedLocations(String projectId) async {
  final locations = [
    {
      'fields': {
        'name': {'stringValue': 'Building 32'},
        'description': {'stringValue': 'Main Computer Science Building'},
        'address': {'stringValue': '32 Vassar Street, Cambridge, MA'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
      }
    },
    {
      'fields': {
        'name': {'stringValue': 'Building 36'},
        'description': {'stringValue': 'Electrical Engineering Lab'},
        'address': {'stringValue': '36 Vassar Street, Cambridge, MA'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
      }
    },
  ];

  for (int i = 0; i < locations.length; i++) {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/locations/location-$i';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(locations[i]),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Location ${i + 1} seeded');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to seed location ${i + 1}: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seeding location ${i + 1}: $e');
      }
    }
  }
}

Future<void> seedInventoryItems(String projectId) async {
  final items = [
    {
      'fields': {
        'name': {'stringValue': 'Dell Laptop XPS 13'},
        'description': {
          'stringValue': 'High-performance laptop for development'
        },
        'category': {'stringValue': 'Laptop'},
        'brand': {'stringValue': 'Dell'},
        'model': {'stringValue': 'XPS-13-2024'},
        'serialNumber': {'stringValue': 'DL001234'},
        'status': {'stringValue': 'available'},
        'price': {'doubleValue': 1299.99},
        'purchaseDate': {
          'stringValue': DateTime.now()
              .subtract(const Duration(days: 90))
              .toIso8601String()
        },
        'warrantyExpiry': {'stringValue': '2027-01-01'},
        'departmentId': {'stringValue': 'dept-0'},
        'locationId': {'stringValue': 'location-0'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        'updatedAt': {'stringValue': DateTime.now().toIso8601String()},
        'specifications': {
          'mapValue': {
            'fields': {
              'RAM': {'stringValue': '16GB'},
              'Storage': {'stringValue': '512GB SSD'},
              'Processor': {'stringValue': 'Intel i7'},
            }
          }
        },
      }
    },
    {
      'fields': {
        'name': {'stringValue': 'MacBook Pro 16"'},
        'description': {
          'stringValue': 'Apple MacBook Pro for software development'
        },
        'category': {'stringValue': 'Laptop'},
        'brand': {'stringValue': 'Apple'},
        'model': {'stringValue': 'MBP-16-2024'},
        'serialNumber': {'stringValue': 'MB001234'},
        'status': {'stringValue': 'available'},
        'price': {'doubleValue': 2499.99},
        'purchaseDate': {
          'stringValue': DateTime.now()
              .subtract(const Duration(days: 60))
              .toIso8601String()
        },
        'warrantyExpiry': {'stringValue': '2025-12-01'},
        'departmentId': {'stringValue': 'dept-0'},
        'locationId': {'stringValue': 'location-0'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        'updatedAt': {'stringValue': DateTime.now().toIso8601String()},
        'specifications': {
          'mapValue': {
            'fields': {
              'RAM': {'stringValue': '32GB'},
              'Storage': {'stringValue': '1TB SSD'},
              'Processor': {'stringValue': 'Apple M3 Pro'},
            }
          }
        },
      }
    },
    {
      'fields': {
        'name': {'stringValue': 'Arduino Uno'},
        'description': {'stringValue': 'Microcontroller development board'},
        'category': {'stringValue': 'Electronics'},
        'brand': {'stringValue': 'Arduino'},
        'model': {'stringValue': 'UNO-R3'},
        'serialNumber': {'stringValue': 'ARD001234'},
        'status': {'stringValue': 'available'},
        'price': {'doubleValue': 25.99},
        'purchaseDate': {
          'stringValue': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String()
        },
        'warrantyExpiry': {'stringValue': '2025-04-01'},
        'departmentId': {'stringValue': 'dept-1'},
        'locationId': {'stringValue': 'location-1'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        'updatedAt': {'stringValue': DateTime.now().toIso8601String()},
        'specifications': {
          'mapValue': {
            'fields': {
              'Microcontroller': {'stringValue': 'ATmega328P'},
              'Digital I/O Pins': {'stringValue': '14'},
              'Analog Input Pins': {'stringValue': '6'},
            }
          }
        },
      }
    },
    {
      'fields': {
        'name': {'stringValue': 'Raspberry Pi 4'},
        'description': {'stringValue': 'Single-board computer for projects'},
        'category': {'stringValue': 'Computer'},
        'brand': {'stringValue': 'Raspberry Pi Foundation'},
        'model': {'stringValue': 'PI4-8GB'},
        'serialNumber': {'stringValue': 'RPI001234'},
        'status': {'stringValue': 'available'},
        'price': {'doubleValue': 75.99},
        'purchaseDate': {
          'stringValue': DateTime.now()
              .subtract(const Duration(days: 45))
              .toIso8601String()
        },
        'warrantyExpiry': {'stringValue': '2025-11-01'},
        'departmentId': {'stringValue': 'dept-0'},
        'locationId': {'stringValue': 'location-2'},
        'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        'updatedAt': {'stringValue': DateTime.now().toIso8601String()},
        'specifications': {
          'mapValue': {
            'fields': {
              'RAM': {'stringValue': '8GB'},
              'CPU': {'stringValue': 'Quad-core ARM Cortex-A72'},
              'Storage': {'stringValue': 'MicroSD'},
            }
          }
        },
      }
    },
  ];

  for (int i = 0; i < items.length; i++) {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/inventory_items';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(items[i]),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Inventory item ${i + 1} seeded');
        }
      } else {
        if (kDebugMode) {
          print(
              '❌ Failed to seed inventory item ${i + 1}: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seeding inventory item ${i + 1}: $e');
      }
    }
  }
}

Future<void> seedTestUser(String projectId) async {
  final userId = 'APduHk4yn8TL1W9oahqYI0w4efU2'; // From the error message

  final userData = {
    'fields': {
      'email': {'stringValue': 'admin@mit.edu'},
      'firstName': {'stringValue': 'Test'},
      'lastName': {'stringValue': 'Admin'},
      'displayName': {'stringValue': 'Test Admin'},
      'role': {'stringValue': 'admin'},
      'department': {'stringValue': 'IT Department'},
      'isActive': {'booleanValue': true},
      'createdAt': {'stringValue': DateTime.now().toIso8601String()},
      'lastLoginAt': {'stringValue': DateTime.now().toIso8601String()},
      'permissions': {
        'mapValue': {
          'fields': {
            'canManageUsers': {'booleanValue': true},
            'canManageComponents': {'booleanValue': true},
            'canManageLaboratories': {'booleanValue': true},
            'canManageDeployments': {'booleanValue': true},
            'canViewAnalytics': {'booleanValue': true},
          }
        }
      },
    }
  };

  final url =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$userId';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('✅ Test user document created');
      }
    } else {
      if (kDebugMode) {
        print('❌ Failed to create test user: ${response.statusCode}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error creating test user: $e');
    }
  }
}
