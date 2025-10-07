import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/inventory_models.dart';

/// Centralized Firestore service for all collections
class FirestoreDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Simple in-memory caches to avoid repeated reads for the same referenced docs
  final Map<String, String> _departmentCache = {};
  final Map<String, String> _locationCache = {};
  final Map<String, String> _itemCache = {};
  final Map<String, String> _userCache =
      {}; // key: uid or email -> display name

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

  /// Returns deployments enriched with resolved department/location/user/item names.
  /// This implementation deduplicates lookups across a snapshot using simple
  /// in-memory caches to avoid N x M repeated reads.
  Stream<List<Map<String, dynamic>>> getEnrichedDeployments() {
    return _firestore
        .collection('deployments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Convert docs to mutable maps and collect referenced ids
      final deployments = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      final deptIds = <String>{};
      final locIds = <String>{};
      final itemIds = <String>{};
      final userIds = <String>{};
      final userEmails = <String>{};

      for (final d in deployments) {
        final String? deptId = d['departmentId'] as String?;
        if (deptId != null &&
            deptId.isNotEmpty &&
            !_departmentCache.containsKey(deptId)) {
          deptIds.add(deptId);
        }

        final String? locId = d['locationId'] as String?;
        if (locId != null &&
            locId.isNotEmpty &&
            !_locationCache.containsKey(locId)) {
          locIds.add(locId);
        }

        final String? itemId = d['itemId'] as String?;
        if (itemId != null &&
            itemId.isNotEmpty &&
            !_itemCache.containsKey(itemId)) {
          itemIds.add(itemId);
        }

        final String? deployedBy = d['deployedBy'] as String?;
        final String? requestedBy = d['requestedBy'] as String?;
        final String? requestedByEmail = d['requestedByEmail'] as String?;

        void collectUserIdentifier(String? v) {
          if (v == null || v.isEmpty) return;
          if (v.contains('@')) {
            if (!_userCache.containsKey(v)) userEmails.add(v);
          } else {
            if (!_userCache.containsKey(v)) userIds.add(v);
          }
        }

        collectUserIdentifier(deployedBy);
        collectUserIdentifier(requestedBy);
        collectUserIdentifier(requestedByEmail);
      }

      // Fetch missing departments
      if (deptIds.isNotEmpty) {
        final futures = deptIds
            .map((id) => _firestore.collection('departments').doc(id).get())
            .toList();
        final results = await Future.wait(futures);
        for (final doc in results) {
          if (doc.exists) {
            final data = doc.data();
            _departmentCache[doc.id] = (data != null && data['name'] != null)
                ? data['name'] as String
                : 'Unknown Department';
          } else {
            _departmentCache[doc.id] = 'Unknown Department';
          }
        }
      }

      // Fetch missing locations
      if (locIds.isNotEmpty) {
        final futures = locIds
            .map((id) => _firestore.collection('locations').doc(id).get())
            .toList();
        final results = await Future.wait(futures);
        for (final doc in results) {
          if (doc.exists) {
            final data = doc.data();
            _locationCache[doc.id] = (data != null && data['name'] != null)
                ? data['name'] as String
                : 'Unknown Location';
          } else {
            _locationCache[doc.id] = 'Unknown Location';
          }
        }
      }

      // Fetch missing items
      if (itemIds.isNotEmpty) {
        final futures = itemIds
            .map((id) => _firestore.collection('items').doc(id).get())
            .toList();
        final results = await Future.wait(futures);
        for (final doc in results) {
          if (doc.exists) {
            final data = doc.data();
            // attempt common name fields
            final name =
                (data != null && (data['name'] ?? data['itemName']) != null)
                    ? (data['name'] ?? data['itemName']) as String
                    : 'Item';
            _itemCache[doc.id] = name;
          } else {
            _itemCache[doc.id] = 'Item';
          }
        }
      }

      // Fetch missing user docs by uid
      if (userIds.isNotEmpty) {
        final futures = userIds
            .map((id) => _firestore.collection('users').doc(id).get())
            .toList();
        final results = await Future.wait(futures);
        for (final doc in results) {
          if (doc.exists) {
            final u = doc.data();
            final first = u?['firstName'] ?? '';
            final last = u?['lastName'] ?? '';
            final display = (('$first $last').trim().isNotEmpty)
                ? ('$first $last').trim()
                : (u?['displayName'] ?? doc.id) as String;
            _userCache[doc.id] = display;
          } else {
            _userCache[doc.id] = doc.id;
          }
        }
      }

      // Fetch missing user docs by email (one query per email). Cache by email and by uid when available
      if (userEmails.isNotEmpty) {
        final futures = userEmails.map((email) async {
          final q = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            final doc = q.docs.first;
            final u = doc.data();
            final first = u['firstName'] ?? '';
            final last = u['lastName'] ?? '';
            final display = (('$first $last').trim().isNotEmpty)
                ? ('$first $last').trim()
                : (u['displayName'] ?? email) as String;
            // cache by email and uid
            _userCache[email] = display;
            _userCache[doc.id] = display;
          } else {
            _userCache[email] = email;
          }
        }).toList();

        await Future.wait(futures);
      }

      // Assemble final enriched deployments
      final enriched = deployments.map((d) {
        final Map<String, dynamic> out = Map<String, dynamic>.from(d);

        final String? deptId = d['departmentId'] as String?;
        out['department'] = (deptId != null && deptId.isNotEmpty)
            ? (_departmentCache[deptId] ?? 'Unknown Department')
            : (d['department'] as String? ?? 'Unknown Department');

        final String? locId = d['locationId'] as String?;
        out['location'] = (locId != null && locId.isNotEmpty)
            ? (_locationCache[locId] ?? 'Unknown Location')
            : (d['location'] as String? ?? 'Unknown Location');

        final String? itemId = d['itemId'] as String?;
        out['itemName'] = (d['itemName'] as String?) ??
            (itemId != null && itemId.isNotEmpty
                ? (_itemCache[itemId] ?? 'Item')
                : 'Item');

        String? userIdentifier;
        if ((d['deployedBy'] as String?)?.isNotEmpty ?? false) {
          userIdentifier = d['deployedBy'] as String?;
        } else if ((d['requestedBy'] as String?)?.isNotEmpty ?? false) {
          userIdentifier = d['requestedBy'] as String?;
        } else if ((d['requestedByEmail'] as String?)?.isNotEmpty ?? false) {
          userIdentifier = d['requestedByEmail'] as String?;
        }

        if (userIdentifier != null && userIdentifier.isNotEmpty) {
          out['requestedBy'] = _userCache[userIdentifier] ?? userIdentifier;
        } else {
          out['requestedBy'] = d['requestedBy'] as String? ?? 'Unknown User';
        }

        return out;
      }).toList();

      return enriched;
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
        // Count all active deployments as active
        stats['active'] = stats['active']! + 1;

        // Check if this active deployment is also overdue
        final returnDate = data['expectedReturnDate'];
        if (returnDate != null) {
          DateTime? expectedReturn;
          if (returnDate is Timestamp) {
            expectedReturn = returnDate.toDate();
          } else if (returnDate is String) {
            expectedReturn = DateTime.tryParse(returnDate);
          }

          if (expectedReturn != null && expectedReturn.isBefore(now)) {
            stats['overdue'] = stats['overdue']! + 1;
          }
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

// Enriched deployments provider (resolves department/location/user names)
final recentEnrichedDeploymentsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(firestoreDataServiceProvider);
  return service.getEnrichedDeployments();
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
