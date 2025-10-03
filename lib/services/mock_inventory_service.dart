import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/inventory_models.dart';

// Mock Inventory Service for testing without Firebase
class MockInventoryService {
  // Mock departments
  static final List<Department> _mockDepartments = [
    Department(
      id: 'cs-dept',
      code: 'CS',
      name: 'Computer Science',
      description: 'Computer Science Department',
      headOfDepartment: 'Dr. Smith',
      createdAt: DateTime.now(),
    ),
    Department(
      id: 'ee-dept',
      code: 'EE',
      name: 'Electrical Engineering',
      description: 'Electrical Engineering Department',
      headOfDepartment: 'Dr. Johnson',
      createdAt: DateTime.now(),
    ),
    Department(
      id: 'me-dept',
      code: 'ME',
      name: 'Mechanical Engineering',
      description: 'Mechanical Engineering Department',
      headOfDepartment: 'Dr. Williams',
      createdAt: DateTime.now(),
    ),
  ];

  // Mock locations
  static final List<Location> _mockLocations = [
    Location(
      id: 'building-32',
      name: 'Computer Lab 1',
      building: 'Building 32',
      room: 'Room 101',
      description: 'Main Computer Science Building',
      capacity: 30,
      createdAt: DateTime.now(),
    ),
    Location(
      id: 'building-36',
      name: 'Electronics Lab',
      building: 'Building 36',
      room: 'Room 205',
      description: 'Electrical Engineering Lab',
      capacity: 25,
      createdAt: DateTime.now(),
    ),
    Location(
      id: 'lab-room-101',
      name: 'Hardware Lab',
      building: 'Building 32',
      room: 'Room 102',
      description: 'Computer Hardware Lab',
      capacity: 20,
      createdAt: DateTime.now(),
    ),
  ];

  // Mock inventory items
  static final List<InventoryItem> _mockItems = [
    InventoryItem(
      id: 'item-1',
      name: 'Dell Laptop XPS 13',
      description: 'High-performance laptop for development',
      category: 'Laptop',
      brand: 'Dell',
      model: 'XPS-13-2024',
      serialNumber: 'DL001234',
      status: 'available',
      price: 1299.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
      warrantyExpiry: '2027-01-01',
      departmentId: 'cs-dept',
      locationId: 'building-32',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specifications: {
        'RAM': '16GB',
        'Storage': '512GB SSD',
        'Processor': 'Intel i7',
      },
    ),
    InventoryItem(
      id: 'item-2',
      name: 'MacBook Pro 16"',
      description: 'Apple MacBook Pro for software development',
      category: 'Laptop',
      brand: 'Apple',
      model: 'MBP-16-2024',
      serialNumber: 'MB001234',
      status: 'available',
      price: 2499.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
      warrantyExpiry: '2025-12-01',
      departmentId: 'cs-dept',
      locationId: 'building-32',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specifications: {
        'RAM': '32GB',
        'Storage': '1TB SSD',
        'Processor': 'Apple M3 Pro',
      },
    ),
    InventoryItem(
      id: 'item-3',
      name: 'Arduino Uno',
      description: 'Microcontroller development board',
      category: 'Electronics',
      brand: 'Arduino',
      model: 'UNO-R3',
      serialNumber: 'ARD001234',
      status: 'available',
      price: 25.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      warrantyExpiry: '2025-04-01',
      departmentId: 'ee-dept',
      locationId: 'building-36',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specifications: {
        'Microcontroller': 'ATmega328P',
        'Digital I/O Pins': '14',
        'Analog Input Pins': '6',
      },
    ),
    InventoryItem(
      id: 'item-4',
      name: 'Raspberry Pi 4',
      description: 'Single-board computer for projects',
      category: 'Computer',
      brand: 'Raspberry Pi Foundation',
      model: 'PI4-8GB',
      serialNumber: 'RPI001234',
      status: 'available',
      price: 75.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 45)),
      warrantyExpiry: '2025-11-01',
      departmentId: 'cs-dept',
      locationId: 'lab-room-101',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specifications: {
        'RAM': '8GB',
        'CPU': 'Quad-core ARM Cortex-A72',
        'Storage': 'MicroSD',
      },
    ),
    InventoryItem(
      id: 'item-5',
      name: 'Digital Oscilloscope',
      description: 'High-precision digital oscilloscope',
      category: 'Test Equipment',
      brand: 'Rigol',
      model: 'DS1054Z',
      serialNumber: 'OSC001234',
      status: 'in-use',
      price: 399.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
      warrantyExpiry: '2026-08-01',
      departmentId: 'ee-dept',
      locationId: 'building-36',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      specifications: {
        'Bandwidth': '50MHz',
        'Channels': '4',
        'Sample Rate': '1GSa/s',
      },
    ),
  ];

  // Get items by status
  Stream<List<InventoryItem>> getItemsByStatus(String status) {
    return Stream.value(
      _mockItems.where((item) => item.status == status).toList(),
    );
  }

  // Get all items
  Stream<List<InventoryItem>> getAllItems() {
    return Stream.value(_mockItems);
  }

  // Get departments
  Stream<List<Department>> getDepartments() {
    return Stream.value(_mockDepartments);
  }

  // Get locations
  Stream<List<Location>> getLocations() {
    return Stream.value(_mockLocations);
  }

  // Get item by ID
  Future<InventoryItem?> getItemById(String id) async {
    try {
      return _mockItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add item
  Future<String> addItem(InventoryItem item) async {
    final newId = 'item-${_mockItems.length + 1}';
    final newItem = InventoryItem(
      id: newId,
      name: item.name,
      description: item.description,
      category: item.category,
      brand: item.brand,
      model: item.model,
      serialNumber: item.serialNumber,
      status: item.status,
      price: item.price,
      purchaseDate: item.purchaseDate,
      warrantyExpiry: item.warrantyExpiry,
      locationId: item.locationId,
      departmentId: item.departmentId,
      specifications: item.specifications,
      images: item.images,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockItems.add(newItem);
    return newId;
  }

  // Update item
  Future<void> updateItem(String id, Map<String, dynamic> updates) async {
    final index = _mockItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _mockItems[index];
      _mockItems[index] = item.copyWith(
        updatedAt: DateTime.now(),
        status: updates['status'] ?? item.status,
      );
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    _mockItems.removeWhere((item) => item.id == id);
  }

  // Update item status
  Future<void> updateItemStatus(String itemId, String status) async {
    final index = _mockItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _mockItems[index];
      _mockItems[index] = item.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }
}

// Mock provider
final mockInventoryServiceProvider = Provider<MockInventoryService>((ref) {
  return MockInventoryService();
});
