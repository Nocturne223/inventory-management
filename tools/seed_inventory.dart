import 'dart:convert';
import 'dart:io';

// Simple script to seed inventory data using Firestore REST API
void main() async {
  print('🌱 Seeding inventory data to Firestore...');

  const projectId = 'inventory-management-aefea';

  try {
    // Seed inventory items
    await seedInventoryItems(projectId);

    print('✅ Inventory data seeded successfully!');
  } catch (e) {
    print('❌ Error seeding data: $e');
    exit(1);
  }
}

Future<void> seedInventoryItems(String projectId) async {
  print('📦 Seeding inventory items...');

  final items = [
    {
      'id': 'item_001',
      'name': 'Dell XPS 13',
      'description': 'High-performance ultrabook laptop',
      'category': 'Electronics',
      'subcategory': 'Laptops',
      'brand': 'Dell',
      'model': 'XPS 13',
      'serialNumber': 'DXP001',
      'status': 'available',
      'condition': 'new',
      'location': 'warehouse',
      'department': 'IT',
      'purchaseDate': '2024-01-15',
      'purchasePrice': 1299.99,
      'currentValue': 1199.99,
      'warranty': {
        'startDate': '2024-01-15',
        'endDate': '2027-01-15',
        'provider': 'Dell',
        'type': 'Extended Warranty'
      },
      'specifications': {
        'processor': 'Intel Core i7',
        'memory': '16GB RAM',
        'storage': '512GB SSD',
        'display': '13.3 inch 4K',
        'weight': '2.8 lbs'
      },
      'assignedTo': null,
      'maintenanceHistory': [],
      'notes': 'Premium ultrabook for development work',
      'tags': ['laptop', 'development', 'portable'],
      'barcodeData': 'DXP001',
      'lastUpdated': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item_002',
      'name': 'MacBook Pro 16"',
      'description': 'Professional laptop for development and design',
      'category': 'Electronics',
      'subcategory': 'Laptops',
      'brand': 'Apple',
      'model': 'MacBook Pro 16-inch',
      'serialNumber': 'MBP002',
      'status': 'available',
      'condition': 'new',
      'location': 'warehouse',
      'department': 'IT',
      'purchaseDate': '2024-02-01',
      'purchasePrice': 2499.99,
      'currentValue': 2299.99,
      'warranty': {
        'startDate': '2024-02-01',
        'endDate': '2025-02-01',
        'provider': 'Apple',
        'type': 'Limited Warranty'
      },
      'specifications': {
        'processor': 'M3 Pro',
        'memory': '18GB Unified Memory',
        'storage': '512GB SSD',
        'display': '16.2-inch Liquid Retina XDR',
        'weight': '4.7 lbs'
      },
      'assignedTo': null,
      'maintenanceHistory': [],
      'notes': 'High-performance laptop for video editing and development',
      'tags': ['laptop', 'development', 'design', 'professional'],
      'barcodeData': 'MBP002',
      'lastUpdated': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item_003',
      'name': 'Arduino Uno',
      'description': 'Microcontroller board for electronics projects',
      'category': 'Electronics',
      'subcategory': 'Development Boards',
      'brand': 'Arduino',
      'model': 'Uno R3',
      'serialNumber': 'ARD003',
      'status': 'available',
      'condition': 'new',
      'location': 'lab',
      'department': 'Engineering',
      'purchaseDate': '2024-01-20',
      'purchasePrice': 25.99,
      'currentValue': 23.99,
      'warranty': {
        'startDate': '2024-01-20',
        'endDate': '2025-01-20',
        'provider': 'Arduino',
        'type': 'Standard Warranty'
      },
      'specifications': {
        'microcontroller': 'ATmega328P',
        'operating_voltage': '5V',
        'input_voltage': '7-12V',
        'digital_io_pins': '14',
        'analog_input_pins': '6'
      },
      'assignedTo': null,
      'maintenanceHistory': [],
      'notes': 'Perfect for IoT and robotics projects',
      'tags': ['microcontroller', 'iot', 'development', 'education'],
      'barcodeData': 'ARD003',
      'lastUpdated': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item_004',
      'name': 'Raspberry Pi 4',
      'description': 'Single-board computer for various applications',
      'category': 'Electronics',
      'subcategory': 'Single Board Computers',
      'brand': 'Raspberry Pi Foundation',
      'model': 'Raspberry Pi 4 Model B',
      'serialNumber': 'RPI004',
      'status': 'available',
      'condition': 'new',
      'location': 'lab',
      'department': 'Engineering',
      'purchaseDate': '2024-01-25',
      'purchasePrice': 75.00,
      'currentValue': 70.00,
      'warranty': {
        'startDate': '2024-01-25',
        'endDate': '2025-01-25',
        'provider': 'Raspberry Pi Foundation',
        'type': 'Standard Warranty'
      },
      'specifications': {
        'processor': 'Broadcom BCM2711',
        'memory': '4GB LPDDR4',
        'connectivity': 'WiFi, Bluetooth, Ethernet',
        'ports': 'USB 3.0, USB 2.0, HDMI',
        'gpio_pins': '40'
      },
      'assignedTo': null,
      'maintenanceHistory': [],
      'notes': 'Versatile computer for learning and projects',
      'tags': ['computer', 'iot', 'learning', 'projects'],
      'barcodeData': 'RPI004',
      'lastUpdated': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    }
  ];

  for (var item in items) {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/inventory_items';

    try {
      final response = await HttpClient().postUrl(Uri.parse(url))
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'fields': _convertToFirestoreFields(item)}));

      final httpResponse = await response.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      if (httpResponse.statusCode == 200) {
        print('✅ Created item: ${item['name']}');
      } else {
        print(
            '❌ Failed to create item ${item['name']}: ${httpResponse.statusCode}');
        print('Response: $responseBody');
      }
    } catch (e) {
      print('❌ Error creating item ${item['name']}: $e');
    }
  }
}

Map<String, dynamic> _convertToFirestoreFields(Map<String, dynamic> data) {
  final fields = <String, dynamic>{};

  for (var entry in data.entries) {
    fields[entry.key] = _convertValue(entry.value);
  }

  return fields;
}

Map<String, dynamic> _convertValue(dynamic value) {
  if (value is String) {
    return {'stringValue': value};
  } else if (value is int) {
    return {'integerValue': value.toString()};
  } else if (value is double) {
    return {'doubleValue': value};
  } else if (value is bool) {
    return {'booleanValue': value};
  } else if (value is List) {
    return {
      'arrayValue': {
        'values': value.map((item) => _convertValue(item)).toList()
      }
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': _convertToFirestoreFields(value.cast<String, dynamic>())
      }
    };
  } else if (value == null) {
    return {'nullValue': null};
  } else {
    return {'stringValue': value.toString()};
  }
}
