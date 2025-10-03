import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Standalone script to seed inventory items into the 'items' collection
/// Run with: dart tools/seed_inventory_items.dart
void main() async {
  print('🚀 Starting inventory items seeding...');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('items');

    // Check if our specific seeded items already exist
    final existingSeededItems = await collection.where('serialNumber',
        whereIn: ['DXP001', 'MBP002', 'ARD003', 'RPI004']).get();

    if (existingSeededItems.docs.isNotEmpty) {
      print('✅ Seeded inventory items already exist, skipping seeding');
      print(
          '   Found ${existingSeededItems.docs.length} existing seeded items');
      return;
    }

    // Check total items in collection
    final totalItems = await collection.limit(10).get();
    print('📊 Current items in collection: ${totalItems.docs.length}');

    print('🌱 Seeding complementary inventory items...');

    final items = [
      {
        'name': 'Dell XPS 13',
        'description': 'High-performance ultrabook laptop',
        'category': 'Electronics',
        'brand': 'Dell',
        'model': 'XPS 13',
        'serialNumber': 'DXP001',
        'status': 'AVAILABLE',
        'price': 1299.99,
        'purchaseDate': DateTime(2024, 1, 15).toIso8601String(),
        'warrantyExpiry': '2027-01-15',
        'locationId': 'warehouse',
        'departmentId': 'IT',
        'specifications': {
          'processor': 'Intel Core i7',
          'memory': '16GB RAM',
          'storage': '512GB SSD',
          'display': '13.3 inch 4K',
          'weight': '2.8 lbs'
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'MacBook Pro 16"',
        'description': 'Professional laptop for development and design',
        'category': 'Electronics',
        'brand': 'Apple',
        'model': 'MacBook Pro 16-inch',
        'serialNumber': 'MBP002',
        'status': 'AVAILABLE',
        'price': 2499.99,
        'purchaseDate': DateTime(2024, 2, 1).toIso8601String(),
        'warrantyExpiry': '2025-02-01',
        'locationId': 'warehouse',
        'departmentId': 'IT',
        'specifications': {
          'processor': 'M3 Pro',
          'memory': '18GB Unified Memory',
          'storage': '512GB SSD',
          'display': '16.2-inch Liquid Retina XDR',
          'weight': '4.7 lbs'
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Arduino Uno',
        'description': 'Microcontroller board for electronics projects',
        'category': 'Electronics',
        'brand': 'Arduino',
        'model': 'Uno R3',
        'serialNumber': 'ARD003',
        'status': 'AVAILABLE',
        'price': 25.99,
        'purchaseDate': DateTime(2024, 1, 20).toIso8601String(),
        'warrantyExpiry': '2025-01-20',
        'locationId': 'lab',
        'departmentId': 'Engineering',
        'specifications': {
          'microcontroller': 'ATmega328P',
          'operating_voltage': '5V',
          'input_voltage': '7-12V',
          'digital_io_pins': '14',
          'analog_input_pins': '6'
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Raspberry Pi 4',
        'description': 'Single-board computer for various applications',
        'category': 'Electronics',
        'brand': 'Raspberry Pi Foundation',
        'model': 'Raspberry Pi 4 Model B',
        'serialNumber': 'RPI004',
        'status': 'AVAILABLE',
        'price': 75.00,
        'purchaseDate': DateTime(2024, 1, 25).toIso8601String(),
        'warrantyExpiry': '2025-01-25',
        'locationId': 'lab',
        'departmentId': 'Engineering',
        'specifications': {
          'processor': 'Broadcom BCM2711',
          'memory': '4GB LPDDR4',
          'connectivity': 'WiFi, Bluetooth, Ethernet',
          'ports': 'USB 3.0, USB 2.0, HDMI',
          'gpio_pins': '40'
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    // Add items to Firestore
    for (final item in items) {
      await collection.add(item);
      print('✅ Added: ${item['name']}');
    }

    print('🎉 Successfully seeded ${items.length} inventory items!');
    print('📍 Items added to "items" collection with status "AVAILABLE"');
  } catch (e) {
    print('❌ Error seeding inventory items: $e');
  }
}
