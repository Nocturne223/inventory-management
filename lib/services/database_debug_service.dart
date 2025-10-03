import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Debug service to inspect what's actually in the database
class DatabaseDebugService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get raw components data to see the actual structure
  Stream<List<Map<String, dynamic>>> getRawComponents() {
    return _firestore.collection('components').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    });
  }

  // Get components with specific status (case insensitive)
  Stream<List<Map<String, dynamic>>> getComponentsByStatus(String status) {
    return _firestore
        .collection('components')
        .where('status', isEqualTo: status.toUpperCase())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get components with any variation of "available" status
  Stream<List<Map<String, dynamic>>> getAvailableComponents() {
    return _firestore.collection('components').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final status = data['status']?.toString().toLowerCase() ?? '';
        return status.contains('available') ||
            status.contains('active') ||
            status == 'available';
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

// Provider for debug service
final databaseDebugServiceProvider = Provider<DatabaseDebugService>((ref) {
  return DatabaseDebugService();
});

// Provider to get raw components for debugging
final rawComponentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(databaseDebugServiceProvider);
  return service.getRawComponents();
});

// Provider to get available components with flexible status matching
final debugAvailableComponentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(databaseDebugServiceProvider);
  return service.getAvailableComponents();
});
