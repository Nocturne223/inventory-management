import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/inventory_models.dart';

/// Centralized Firestore service for all collections
class FirestoreDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======================
  // DEPARTMENTS COLLECTION
  // ======================
  Stream<List<Department>> getDepartments() {
    return _firestore
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Department.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Department?> getDepartment(String id) async {
    final doc = await _firestore.collection('departments').doc(id).get();
    if (!doc.exists) return null;
    return Department.fromMap(doc.data()!, doc.id);
  }

  Future<String> addDepartment(Department department) async {
    final docRef =
        await _firestore.collection('departments').add(department.toMap());
    return docRef.id;
  }

  // ======================
  // LOCATIONS COLLECTION
  // ======================
  Stream<List<Location>> getLocations() {
    return _firestore
        .collection('locations')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Location.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Location?> getLocation(String id) async {
    final doc = await _firestore.collection('locations').doc(id).get();
    if (!doc.exists) return null;
    return Location.fromMap(doc.data()!, doc.id);
  }

  Future<String> addLocation(Location location) async {
    final docRef =
        await _firestore.collection('locations').add(location.toMap());
    return docRef.id;
  }

  Future<void> updateLocation(
      String id, Map<String, dynamic> locationData) async {
    await _firestore.collection('locations').doc(id).update({
      ...locationData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteLocation(String id) async {
    await _firestore.collection('locations').doc(id).delete();
  }

  // ======================
  // ITEMS COLLECTION
  // ======================
  Stream<List<InventoryItem>> getItems() {
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

  Stream<List<InventoryItem>> getItemsByStatus(String status) {
    return _firestore.collection('items').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final itemStatus = data['status']?.toString().toLowerCase() ?? '';
        final searchStatus = status.toLowerCase();
        return itemStatus == searchStatus ||
            itemStatus == searchStatus.toUpperCase() ||
            itemStatus == 'available' && searchStatus == 'available';
      }).map((doc) {
        return InventoryItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<InventoryItem?> getItem(String id) async {
    final doc = await _firestore.collection('items').doc(id).get();
    if (!doc.exists) return null;
    return InventoryItem.fromMap(doc.data()!, doc.id);
  }

  Future<String> addItem(InventoryItem item) async {
    final docRef = await _firestore.collection('items').add(item.toMap());
    return docRef.id;
  }

  Future<void> updateItem(String id, InventoryItem item) async {
    await _firestore.collection('items').doc(id).update(item.toMap());
  }

  Future<void> updateItemData(String id, Map<String, dynamic> itemData) async {
    await _firestore.collection('items').doc(id).update({
      ...itemData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection('items').doc(id).delete();
  }

  // ======================
  // DEPLOYMENTS COLLECTION
  // ======================
  Stream<List<Map<String, dynamic>>> getDeployments() {
    return _firestore
        .collection('deployments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getActiveDeployments() {
    return _firestore
        .collection('deployments')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getDeployment(String id) async {
    final doc = await _firestore.collection('deployments').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<String> addDeployment(Map<String, dynamic> deployment) async {
    final docRef = await _firestore.collection('deployments').add({
      ...deployment,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ======================
  // SYSTEM_UNITS COLLECTION
  // ======================
  Stream<List<Map<String, dynamic>>> getSystemUnits() {
    return _firestore
        .collection('system_units')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getSystemUnit(String id) async {
    final doc = await _firestore.collection('system_units').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<String> addSystemUnit(Map<String, dynamic> systemUnit) async {
    final docRef = await _firestore.collection('system_units').add({
      ...systemUnit,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ======================
  // USERS COLLECTION
  // ======================
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(id).update({
      ...userData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ======================
  // STATS AND AGGREGATIONS
  // ======================
  Future<Map<String, int>> getInventoryStats() async {
    final itemsSnapshot = await _firestore.collection('items').get();
    final stats = <String, int>{
      'total': itemsSnapshot.docs.length,
      'available': 0,
      'in_use': 0,
      'maintenance': 0,
      'retired': 0,
    };

    for (final doc in itemsSnapshot.docs) {
      final status = doc.data()['status']?.toString().toLowerCase() ?? '';
      if (status.contains('available')) {
        stats['available'] = stats['available']! + 1;
      } else if (status.contains('use') || status.contains('deployed')) {
        stats['in_use'] = stats['in_use']! + 1;
      } else if (status.contains('maintenance')) {
        stats['maintenance'] = stats['maintenance']! + 1;
      } else if (status.contains('retired')) {
        stats['retired'] = stats['retired']! + 1;
      }
    }

    return stats;
  }

  Future<Map<String, int>> getDeploymentStats() async {
    final deploymentsSnapshot =
        await _firestore.collection('deployments').get();
    final stats = <String, int>{
      'total': deploymentsSnapshot.docs.length,
      'active': 0,
      'completed': 0,
      'overdue': 0,
    };

    final now = DateTime.now();
    for (final doc in deploymentsSnapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString().toLowerCase() ?? '';

      if (status == 'active' || status == 'deployed') {
        // Check if overdue first
        bool isOverdue = false;
        final returnDate = data['expectedReturnDate'];
        if (returnDate != null) {
          DateTime? expectedReturn;
          if (returnDate is Timestamp) {
            expectedReturn = returnDate.toDate();
          } else if (returnDate is String) {
            expectedReturn = DateTime.tryParse(returnDate);
          }

          if (expectedReturn != null && expectedReturn.isBefore(now)) {
            isOverdue = true;
            stats['overdue'] = stats['overdue']! + 1;
          }
        }

        // Only count as active if NOT overdue
        if (!isOverdue) {
          stats['active'] = stats['active']! + 1;
        }
      } else if (status == 'overdue') {
        // Deployments with explicit 'overdue' status
        stats['overdue'] = stats['overdue']! + 1;
      } else if (status == 'completed' || status == 'returned') {
        stats['completed'] = stats['completed']! + 1;
      }
    }

    return stats;
  }
}

// Provider for the centralized Firestore service
final firestoreDataServiceProvider = Provider<FirestoreDataService>((ref) {
  return FirestoreDataService();
});

// ======================
// INDIVIDUAL PROVIDERS
// ======================

// Departments
final departmentsProvider = StreamProvider<List<Department>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getDepartments();
});

// Locations
final locationsProvider = StreamProvider<List<Location>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getLocations();
});

// Items (replacing inventory items)
final allItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getItems();
});

final availableItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getItemsByStatus('AVAILABLE');
});

// Deployments
final allDeploymentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getDeployments();
});

final activeDeploymentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getActiveDeployments();
});

// System Units
final systemUnitsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getSystemUnits();
});

// Users
final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getUsers();
});

// Stats
final inventoryStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getInventoryStats();
});

final deploymentStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getDeploymentStats();
});
