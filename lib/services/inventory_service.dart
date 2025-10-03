import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/inventory_models.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inventory Items
  Stream<List<InventoryItem>> getInventoryItems() {
    return _firestore
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<InventoryItem?> getInventoryItem(String id) async {
    final doc = await _firestore.collection('items').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return InventoryItem.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> addInventoryItem(InventoryItem item) async {
    final docRef = await _firestore.collection('items').add(item.toMap());
    return docRef.id;
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _firestore.collection('items').doc(item.id).update(item.toMap());
  }

  Future<void> deleteInventoryItem(String id) async {
    await _firestore.collection('items').doc(id).delete();
  }

  // Search and Filter
  Stream<List<InventoryItem>> searchInventoryItems(String query) {
    return _firestore
        .collection('items')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<InventoryItem>> getItemsByCategory(String category) {
    return _firestore
        .collection('items')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<InventoryItem>> getItemsByStatus(String status) {
    return _firestore
        .collection('items')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<InventoryItem>> getItemsByDepartment(String departmentId) {
    return _firestore
        .collection('items')
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Departments
  Stream<List<Department>> getDepartments() {
    return _firestore.collection('departments').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Department.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Department?> getDepartment(String id) async {
    final doc = await _firestore.collection('departments').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Department.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> addDepartment(Department department) async {
    final docRef =
        await _firestore.collection('departments').add(department.toMap());
    return docRef.id;
  }

  Future<void> updateDepartment(Department department) async {
    await _firestore
        .collection('departments')
        .doc(department.id)
        .update(department.toMap());
  }

  Future<void> deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
  }

  // Locations
  Stream<List<Location>> getLocations() {
    return _firestore.collection('locations').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Location.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Location?> getLocation(String id) async {
    final doc = await _firestore.collection('locations').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Location.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> addLocation(Location location) async {
    final docRef =
        await _firestore.collection('locations').add(location.toMap());
    return docRef.id;
  }

  Future<void> updateLocation(Location location) async {
    await _firestore
        .collection('locations')
        .doc(location.id)
        .update(location.toMap());
  }

  Future<void> deleteLocation(String id) async {
    await _firestore.collection('locations').doc(id).delete();
  }

  // Statistics
  Future<Map<String, int>> getInventoryStats() async {
    final items = await _firestore.collection('items').get();
    final departments = await _firestore.collection('departments').get();
    final locations = await _firestore.collection('locations').get();

    int available = 0;
    int inUse = 0;
    int maintenance = 0;
    int retired = 0;

    for (var doc in items.docs) {
      final status = doc.data()['status'] ?? 'available';
      switch (status) {
        case 'available':
          available++;
          break;
        case 'in-use':
          inUse++;
          break;
        case 'maintenance':
          maintenance++;
          break;
        case 'retired':
          retired++;
          break;
      }
    }

    return {
      'totalItems': items.docs.length,
      'departments': departments.docs.length,
      'locations': locations.docs.length,
      'available': available,
      'inUse': inUse,
      'maintenance': maintenance,
      'retired': retired,
    };
  }

  // Get category distribution for pie chart
  Future<Map<String, double>> getCategoryDistribution() async {
    try {
      final items = await _firestore.collection('items').get();
      final categoryCount = <String, int>{};

      // Count items by category
      for (var doc in items.docs) {
        final category = doc.data()['category'] ?? 'Other';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      final total = items.docs.length;
      if (total == 0) {
        return {'No Data': 100.0};
      }

      // Convert to percentages
      final distribution = <String, double>{};
      categoryCount.forEach((category, count) {
        distribution[category] = (count / total) * 100;
      });

      return distribution;
    } catch (e) {
      print('Error getting category distribution: $e');
      return {'Error': 100.0};
    }
  }

  // Categories
  List<String> getCategories() {
    return [
      'Computer',
      'Monitor',
      'Printer',
      'Network Equipment',
      'Server',
      'Storage',
      'Projector',
      'Audio/Video',
      'Software',
      'Furniture',
      'Other',
    ];
  }

  List<String> getStatuses() {
    return [
      'available',
      'in-use',
      'maintenance',
      'retired',
    ];
  }
}
