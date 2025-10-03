// Simple Dart script for seeding inventory data
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Simple Firebase initialization without Flutter
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBcFl9UkxIWQc3l3IYeQr_8J8LhQ5oBjOI",
      authDomain: "inventory-management-8fb2e.firebaseapp.com",
      projectId: "inventory-management-8fb2e",
      storageBucket: "inventory-management-8fb2e.firebasestorage.app",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abcd1234efgh5678",
    ),
  );
}

void main(List<String> args) async {
  try {
    print('Initializing Firebase...');
    await initializeFirebase();

    final firestore = FirebaseFirestore.instance;
    print('Firebase initialized successfully!');

    if (args.isEmpty || args[0] == 'help') {
      print('\nUsage:');
      print('  dart simple_seed.dart [command]');
      print('\nCommands:');
      print('  stats   - Show database statistics');
      print('  seed    - Add sample data to collections');
      print('  clear   - Clear all collections');
      print('  help    - Show this help message');
      return;
    }

    final command = args[0];

    switch (command) {
      case 'stats':
        await showStats(firestore);
        break;
      case 'seed':
        await seedData(firestore);
        break;
      case 'clear':
        await clearData(firestore);
        break;
      default:
        print('Unknown command: $command');
        print('Use "help" to see available commands.');
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> showStats(FirebaseFirestore firestore) async {
  print('\nDatabase Statistics:');
  print('==================');

  final collections = [
    'departments',
    'locations',
    'items',
    'system_units',
    'deployments'
  ];

  for (final collection in collections) {
    try {
      final snapshot = await firestore.collection(collection).get();
      print('$collection: ${snapshot.docs.length} documents');
    } catch (e) {
      print('$collection: Error reading ($e)');
    }
  }
}

Future<void> seedData(FirebaseFirestore firestore) async {
  print('\nSeeding sample data...');

  // Sample departments
  await addSampleDepartments(firestore);

  // Sample locations
  await addSampleLocations(firestore);

  // Sample items
  await addSampleItems(firestore);

  print('Sample data seeded successfully!');
}

Future<void> clearData(FirebaseFirestore firestore) async {
  print('\nClearing all data...');

  final collections = [
    'departments',
    'locations',
    'items',
    'system_units',
    'deployments'
  ];

  for (final collection in collections) {
    try {
      final snapshot = await firestore.collection(collection).get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Cleared $collection (${snapshot.docs.length} documents)');
    } catch (e) {
      print('Error clearing $collection: $e');
    }
  }

  print('All data cleared successfully!');
}

Future<void> addSampleDepartments(FirebaseFirestore firestore) async {
  final departments = [
    {'id': 'IT', 'name': 'Information Technology'},
    {'id': 'HR', 'name': 'Human Resources'},
    {'id': 'FIN', 'name': 'Finance'},
    {'id': 'ENG', 'name': 'Engineering'},
    {'id': 'OPS', 'name': 'Operations'},
  ];

  final batch = firestore.batch();

  for (final dept in departments) {
    final ref = firestore.collection('departments').doc(dept['id'] as String);
    batch.set(ref, dept);
  }

  await batch.commit();
  print('Added ${departments.length} departments');
}

Future<void> addSampleLocations(FirebaseFirestore firestore) async {
  final locations = [
    {'id': 'BLDG-A', 'name': 'Building A', 'address': '123 Main St'},
    {'id': 'BLDG-B', 'name': 'Building B', 'address': '456 Oak Ave'},
    {'id': 'WH-1', 'name': 'Warehouse 1', 'address': '789 Industrial Blvd'},
    {'id': 'DC-1', 'name': 'Data Center 1', 'address': '321 Tech Park'},
    {'id': 'OFF-1', 'name': 'Office Building 1', 'address': '654 Business Way'},
  ];

  final batch = firestore.batch();

  for (final location in locations) {
    final ref = firestore.collection('locations').doc(location['id'] as String);
    batch.set(ref, location);
  }

  await batch.commit();
  print('Added ${locations.length} locations');
}

Future<void> addSampleItems(FirebaseFirestore firestore) async {
  final items = [
    {
      'id': 'LAPTOP-001',
      'name': 'Dell Laptop',
      'category': 'Computer',
      'department': 'IT',
      'location': 'BLDG-A',
      'status': 'Available',
      'quantity': 25,
    },
    {
      'id': 'PRINTER-001',
      'name': 'HP LaserJet Printer',
      'category': 'Printer',
      'department': 'IT',
      'location': 'BLDG-B',
      'status': 'Available',
      'quantity': 10,
    },
    {
      'id': 'DESK-001',
      'name': 'Standing Desk',
      'category': 'Furniture',
      'department': 'HR',
      'location': 'OFF-1',
      'status': 'Available',
      'quantity': 50,
    },
    {
      'id': 'SERVER-001',
      'name': 'Dell PowerEdge Server',
      'category': 'Server',
      'department': 'IT',
      'location': 'DC-1',
      'status': 'In Use',
      'quantity': 5,
    },
    {
      'id': 'PHONE-001',
      'name': 'Office Phone',
      'category': 'Communication',
      'department': 'HR',
      'location': 'BLDG-A',
      'status': 'Available',
      'quantity': 100,
    },
  ];

  final batch = firestore.batch();

  for (final item in items) {
    final ref = firestore.collection('items').doc(item['id'] as String);
    batch.set(ref, item);
  }

  await batch.commit();
  print('Added ${items.length} items');
}
