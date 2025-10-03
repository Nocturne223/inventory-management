import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/core/config/firebase_config.dart';

/// Simple Dart script to seed data into Firestore
/// Usage: dart tools/seed_data.dart [command]
/// Commands:
///   seed    - Add sample data
///   clear   - Clear all data
///   stats   - Show current data statistics

void main(List<String> args) async {
  if (args.isEmpty) {
    printHelp();
    return;
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
    print('✅ Firebase initialized');

    final command = args[0];
    switch (command) {
      case 'seed':
        await seedData();
        break;
      case 'clear':
        await clearData();
        break;
      case 'stats':
        await showStats();
        break;
      default:
        printHelp();
    }
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void printHelp() {
  print('''
Data Seeding Tool for Inventory Management

Usage: dart tools/seed_data.dart [command]

Commands:
  seed    Add sample data to the database
  clear   Clear all data from the database
  stats   Show current database statistics

Examples:
  dart tools/seed_data.dart seed
  dart tools/seed_data.dart stats
  dart tools/seed_data.dart clear
''');
}

Future<void> seedData() async {
  print('🌱 Seeding sample data...');
  final db = FirebaseFirestore.instance;

  // Seed departments
  print('📁 Adding departments...');
  final departments = [
    {
      'id': 'dept_001',
      'code': 'CBA',
      'name': 'College of Business & Accounting',
      'description': 'Business and accounting programs',
      'contact_person': 'Jane Smith',
      'contact_email': 'jane.smith@college.edu',
      'contact_phone': '02-555-1234',
    },
    {
      'id': 'dept_002',
      'code': 'COE',
      'name': 'College of Engineering',
      'description': 'Engineering programs',
      'contact_person': 'John Doe',
      'contact_email': 'john.doe@college.edu',
      'contact_phone': '02-555-2345',
    },
    {
      'id': 'dept_003',
      'code': 'CCS',
      'name': 'College of Computer Studies',
      'description': 'Computer science and IT programs',
      'contact_person': 'Alice Johnson',
      'contact_email': 'alice.johnson@college.edu',
      'contact_phone': '02-555-3456',
    },
  ];

  for (final dept in departments) {
    final docId = dept['id'] as String;
    final data = Map<String, dynamic>.from(dept);
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('departments').doc(docId).set(data);
  }

  // Seed locations
  print('📍 Adding locations...');
  final locations = [
    {
      'id': 'loc_001',
      'name': 'Main Building - Lab 101',
      'address': 'Main Building, Floor 1, Room 101',
      'contact_person': 'Tech Staff',
      'phone': '02-555-1111',
      'departmentId': 'dept_003',
      'roomIdentifier': '101',
    },
    {
      'id': 'loc_002',
      'name': 'IT Building - Server Room',
      'address': 'IT Building, Floor 2, Server Room',
      'contact_person': 'Network Admin',
      'phone': '02-555-2222',
      'departmentId': 'dept_003',
      'roomIdentifier': '201',
    },
  ];

  for (final location in locations) {
    final docId = location['id'] as String;
    final data = Map<String, dynamic>.from(location);
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('locations').doc(docId).set(data);
  }

  // Seed items
  print('💻 Adding items...');
  final items = [
    {
      'id': 'item_001',
      'sku': 'ITM-RAM8',
      'name': '8GB DDR4 RAM',
      'description': '8GB DDR4 memory module',
      'categoryId': 'memory',
      'modelNumber': 'DDR4-8GB',
      'minimumStock': 5,
      'isSerialized': false,
      'status': 'active',
      'replacementCost': 75.0,
    },
    {
      'id': 'item_002',
      'sku': 'ITM-SSD256',
      'name': '256GB SSD',
      'description': '256GB Solid State Drive',
      'categoryId': 'storage',
      'modelNumber': 'SSD-256GB',
      'minimumStock': 3,
      'isSerialized': true,
      'status': 'active',
      'replacementCost': 120.0,
    },
    {
      'id': 'item_003',
      'sku': 'ITM-MON24',
      'name': '24" Monitor',
      'description': '24 inch LED monitor',
      'categoryId': 'display',
      'modelNumber': 'MON-24LED',
      'minimumStock': 2,
      'isSerialized': true,
      'status': 'active',
      'replacementCost': 250.0,
    },
  ];

  for (final item in items) {
    final docId = item['id'] as String;
    final data = Map<String, dynamic>.from(item);
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('items').doc(docId).set(data);
  }

  // Seed system units
  print('🖥️ Adding system units...');
  final systemUnits = [
    {
      'id': 'unit_001',
      'unitIdentifier': 'SYS-DESK-001',
      'name': 'Desktop Unit 1',
      'systemType': 'desktop',
      'status': 'available',
      'configurationNotes': 'Standard desktop configuration',
    },
    {
      'id': 'unit_002',
      'unitIdentifier': 'SYS-LAP-001',
      'name': 'Laptop Unit 1',
      'systemType': 'laptop',
      'status': 'deployed',
      'configurationNotes': 'Mobile workstation',
    },
  ];

  for (final unit in systemUnits) {
    final docId = unit['id'] as String;
    final data = Map<String, dynamic>.from(unit);
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('system_units').doc(docId).set(data);
  }

  // Seed deployments
  print('🚀 Adding deployments...');
  final deployments = [
    {
      'id': 'deploy_001',
      'requestNumber': 'REQ-2024-001',
      'requesterId': 'user_001',
      'departmentId': 'dept_003',
      'status': 'completed',
      'deploymentType': 'individual_item',
      'totalItemsCount': 1,
      'purpose': 'Teaching',
      'receiverName': 'Prof. Martinez',
      'roomIdentifier': '101',
    },
  ];

  for (final deployment in deployments) {
    final docId = deployment['id'] as String;
    final data = Map<String, dynamic>.from(deployment);
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    await db.collection('deployments').doc(docId).set(data);
  }

  print('✅ Sample data seeded successfully!');
  await showStats();
}

Future<void> clearData() async {
  print('🗑️ Clearing all data...');
  print('⚠️  This will permanently delete all data!');
  stdout.write('Type "CONFIRM" to proceed: ');
  final confirmation = stdin.readLineSync();

  if (confirmation != 'CONFIRM') {
    print('❌ Operation cancelled');
    return;
  }

  final db = FirebaseFirestore.instance;
  final collections = [
    'departments',
    'locations',
    'items',
    'system_units',
    'deployments'
  ];

  for (final collectionName in collections) {
    final snapshot = await db.collection(collectionName).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    print('🗑️ Cleared $collectionName');
  }

  print('✅ All data cleared');
}

Future<void> showStats() async {
  print('\n📊 Database Statistics:');
  print('=' * 40);

  final db = FirebaseFirestore.instance;
  final collections = [
    'departments',
    'locations',
    'items',
    'system_units',
    'deployments'
  ];
  var totalRecords = 0;

  for (final collectionName in collections) {
    final snapshot = await db.collection(collectionName).get();
    final count = snapshot.docs.length;
    totalRecords += count;
    final displayName = collectionName.replaceAll('_', ' ').toUpperCase();
    print('  $displayName: $count records');
  }

  print('=' * 40);
  print('  TOTAL: $totalRecords records');
  print('');
}
