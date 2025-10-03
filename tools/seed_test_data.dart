import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('Seeding test data...');

  try {
    // Seed Departments
    await seedDepartments(firestore);

    // Seed Locations
    await seedLocations(firestore);

    // Seed some test inventory items
    await seedInventoryItems(firestore);

    // Create a test user document to fix the auth error
    await seedTestUser(firestore);

    print('✅ Test data seeded successfully!');
  } catch (e) {
    print('❌ Error seeding data: $e');
  }
}

Future<void> seedDepartments(FirebaseFirestore firestore) async {
  final departments = [
    {
      'id': 'cs-dept',
      'name': 'Computer Science',
      'description': 'Computer Science Department',
      'head': 'Dr. Smith',
      'contactEmail': 'cs@mit.edu',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'ee-dept',
      'name': 'Electrical Engineering',
      'description': 'Electrical Engineering Department',
      'head': 'Dr. Johnson',
      'contactEmail': 'ee@mit.edu',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'me-dept',
      'name': 'Mechanical Engineering',
      'description': 'Mechanical Engineering Department',
      'head': 'Dr. Williams',
      'contactEmail': 'me@mit.edu',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  final batch = firestore.batch();
  for (final dept in departments) {
    final docRef =
        firestore.collection('departments').doc(dept['id'] as String);
    batch.set(docRef, dept);
  }

  await batch.commit();
  print('✅ Departments seeded');
}

Future<void> seedLocations(FirebaseFirestore firestore) async {
  final locations = [
    {
      'id': 'building-32',
      'name': 'Building 32',
      'description': 'Main Computer Science Building',
      'address': '32 Vassar Street, Cambridge, MA',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'building-36',
      'name': 'Building 36',
      'description': 'Electrical Engineering Lab',
      'address': '36 Vassar Street, Cambridge, MA',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'lab-room-101',
      'name': 'Lab Room 101',
      'description': 'Computer Hardware Lab',
      'address': 'Building 32, Room 101',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  final batch = firestore.batch();
  for (final location in locations) {
    final docRef =
        firestore.collection('locations').doc(location['id'] as String);
    batch.set(docRef, location);
  }

  await batch.commit();
  print('✅ Locations seeded');
}

Future<void> seedInventoryItems(FirebaseFirestore firestore) async {
  final items = [
    {
      'name': 'Dell Laptop XPS 13',
      'description': 'High-performance laptop for development',
      'category': 'Laptop',
      'serialNumber': 'DL001234',
      'modelNumber': 'XPS-13-2024',
      'manufacturer': 'Dell',
      'status': 'available',
      'condition': 'excellent',
      'purchaseDate':
          DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'purchasePrice': 1299.99,
      'warranty': '3 years',
      'departmentId': 'cs-dept',
      'locationId': 'building-32',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'tags': ['laptop', 'development', 'mobile'],
    },
    {
      'name': 'MacBook Pro 16"',
      'description': 'Apple MacBook Pro for software development',
      'category': 'Laptop',
      'serialNumber': 'MB001234',
      'modelNumber': 'MBP-16-2024',
      'manufacturer': 'Apple',
      'status': 'available',
      'condition': 'excellent',
      'purchaseDate':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'purchasePrice': 2499.99,
      'warranty': '1 year',
      'departmentId': 'cs-dept',
      'locationId': 'building-32',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'tags': ['laptop', 'development', 'apple'],
    },
    {
      'name': 'Arduino Uno',
      'description': 'Microcontroller development board',
      'category': 'Electronics',
      'serialNumber': 'ARD001234',
      'modelNumber': 'UNO-R3',
      'manufacturer': 'Arduino',
      'status': 'available',
      'condition': 'good',
      'purchaseDate':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'purchasePrice': 25.99,
      'warranty': '6 months',
      'departmentId': 'ee-dept',
      'locationId': 'building-36',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'tags': ['microcontroller', 'electronics', 'prototyping'],
    },
    {
      'name': 'Raspberry Pi 4',
      'description': 'Single-board computer for projects',
      'category': 'Computer',
      'serialNumber': 'RPI001234',
      'modelNumber': 'PI4-8GB',
      'manufacturer': 'Raspberry Pi Foundation',
      'status': 'available',
      'condition': 'excellent',
      'purchaseDate':
          DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      'purchasePrice': 75.99,
      'warranty': '1 year',
      'departmentId': 'cs-dept',
      'locationId': 'lab-room-101',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'tags': ['computer', 'embedded', 'linux'],
    },
    {
      'name': 'Digital Oscilloscope',
      'description': 'High-precision digital oscilloscope',
      'category': 'Test Equipment',
      'serialNumber': 'OSC001234',
      'modelNumber': 'DS1054Z',
      'manufacturer': 'Rigol',
      'status': 'available',
      'condition': 'excellent',
      'purchaseDate':
          DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      'purchasePrice': 399.99,
      'warranty': '2 years',
      'departmentId': 'ee-dept',
      'locationId': 'building-36',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'tags': ['test-equipment', 'electronics', 'measurement'],
    },
  ];

  final batch = firestore.batch();
  for (final item in items) {
    final docRef = firestore.collection('inventory_items').doc();
    batch.set(docRef, item);
  }

  await batch.commit();
  print('✅ Inventory items seeded');
}

Future<void> seedTestUser(FirebaseFirestore firestore) async {
  // Create the user document that the auth system is looking for
  final userId = 'APduHk4yn8TL1W9oahqYI0w4efU2'; // From the error message

  final userData = {
    'id': userId,
    'email': 'admin@mit.edu',
    'firstName': 'Test',
    'lastName': 'Admin',
    'displayName': 'Test Admin',
    'role': 'admin',
    'department': 'IT Department',
    'isActive': true,
    'createdAt': DateTime.now().toIso8601String(),
    'lastLoginAt': DateTime.now().toIso8601String(),
    'permissions': {
      'canManageUsers': true,
      'canManageComponents': true,
      'canManageLaboratories': true,
      'canManageDeployments': true,
      'canViewAnalytics': true,
    },
  };

  await firestore.collection('users').doc(userId).set(userData);
  print('✅ Test user document created');
}
