import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/inventory_models.dart';

// Firestore-based inventory service
class FirestoreInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get items by status (for deployment dropdown)
  Stream<List<InventoryItem>> getItemsByStatus(String status) {
    // Try multiple status variations to handle different data formats
    return _firestore.collection('items').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final itemStatus = data['status']?.toString().toLowerCase() ?? '';
        final searchStatus = status.toLowerCase();

        // Handle multiple status formats: available, AVAILABLE, Available
        return itemStatus == searchStatus ||
            itemStatus == searchStatus.toUpperCase() ||
            itemStatus == 'available' && searchStatus == 'available';
      }).map((doc) {
        return InventoryItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get all items
  Stream<List<InventoryItem>> getAllItems() {
    return _firestore
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get item by ID
  Future<InventoryItem?> getItemById(String id) async {
    final doc = await _firestore.collection('items').doc(id).get();
    if (!doc.exists) return null;
    return InventoryItem.fromMap(doc.data()!, doc.id);
  }

  // Add new item
  Future<String> addItem(InventoryItem item) async {
    final docRef = await _firestore.collection('items').add(item.toMap());
    return docRef.id;
  }

  // Update existing item
  Future<void> updateItem(String id, InventoryItem item) async {
    await _firestore.collection('items').doc(id).update(item.toMap());
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    await _firestore.collection('items').doc(id).delete();
  }

  // Seed initial data (for testing) - adds complementary items to existing data
  Future<void> seedInitialData() async {
    final collection = _firestore.collection('items');

    // Check if our specific seeded items already exist
    final existingSeededItems = await collection.where('serialNumber',
        whereIn: ['DXP001', 'MBP002', 'ARD003', 'RPI004']).get();

    if (existingSeededItems.docs.isNotEmpty) {
      print('✅ Seeded inventory items already exist, skipping seeding');
      return;
    }

    print('🌱 Seeding complementary inventory items...');

    final items = [
      InventoryItem(
        id: '', // Will be auto-generated
        name: 'Dell XPS 13',
        description: 'High-performance ultrabook laptop',
        category: 'Electronics',
        brand: 'Dell',
        model: 'XPS 13',
        serialNumber: 'DXP001',
        status: 'AVAILABLE', // Use uppercase to match existing data format
        price: 1299.99,
        purchaseDate: DateTime(2024, 1, 15),
        warrantyExpiry: '2027-01-15',
        locationId: 'warehouse',
        departmentId: 'IT',
        specifications: {
          'processor': 'Intel Core i7',
          'memory': '16GB RAM',
          'storage': '512GB SSD',
          'display': '13.3 inch 4K',
          'weight': '2.8 lbs'
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: '',
        name: 'MacBook Pro 16"',
        description: 'Professional laptop for development and design',
        category: 'Electronics',
        brand: 'Apple',
        model: 'MacBook Pro 16-inch',
        serialNumber: 'MBP002',
        status: 'AVAILABLE',
        price: 2499.99,
        purchaseDate: DateTime(2024, 2, 1),
        warrantyExpiry: '2025-02-01',
        locationId: 'warehouse',
        departmentId: 'IT',
        specifications: {
          'processor': 'M3 Pro',
          'memory': '18GB Unified Memory',
          'storage': '512GB SSD',
          'display': '16.2-inch Liquid Retina XDR',
          'weight': '4.7 lbs'
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: '',
        name: 'Arduino Uno',
        description: 'Microcontroller board for electronics projects',
        category: 'Electronics',
        brand: 'Arduino',
        model: 'Uno R3',
        serialNumber: 'ARD003',
        status: 'AVAILABLE',
        price: 25.99,
        purchaseDate: DateTime(2024, 1, 20),
        warrantyExpiry: '2025-01-20',
        locationId: 'lab',
        departmentId: 'Engineering',
        specifications: {
          'microcontroller': 'ATmega328P',
          'operating_voltage': '5V',
          'input_voltage': '7-12V',
          'digital_io_pins': '14',
          'analog_input_pins': '6'
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: '',
        name: 'Raspberry Pi 4',
        description: 'Single-board computer for various applications',
        category: 'Electronics',
        brand: 'Raspberry Pi Foundation',
        model: 'Raspberry Pi 4 Model B',
        serialNumber: 'RPI004',
        status: 'AVAILABLE',
        price: 75.00,
        purchaseDate: DateTime(2024, 1, 25),
        warrantyExpiry: '2025-01-25',
        locationId: 'lab',
        departmentId: 'Engineering',
        specifications: {
          'processor': 'Broadcom BCM2711',
          'memory': '4GB LPDDR4',
          'connectivity': 'WiFi, Bluetooth, Ethernet',
          'ports': 'USB 3.0, USB 2.0, HDMI',
          'gpio_pins': '40'
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Add items to Firestore
    for (final item in items) {
      await collection.add(item.toMap());
      print('✅ Added: ${item.name}');
    }

    print('✅ Inventory seeding completed!');
  }
}

// Provider for the Firestore inventory service
final firestoreInventoryServiceProvider =
    Provider<FirestoreInventoryService>((ref) {
  return FirestoreInventoryService();
});

// Provider for available items (replaces the mock version)
final availableItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(firestoreInventoryServiceProvider);
  return service.getItemsByStatus('available');
});

// Provider for all items
final allItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(firestoreInventoryServiceProvider);
  return service.getAllItems();
});
