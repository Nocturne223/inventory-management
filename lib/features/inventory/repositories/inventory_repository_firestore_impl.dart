import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/inventory_repository.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;

  FirestoreInventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _componentsCol => _firestore.collection('components');
  CollectionReference get _transactionsCol =>
      _firestore.collection('inventory_transactions');
  CollectionReference get _stockLevelsCol =>
      _firestore.collection('stock_levels');

  @override
  Future<void> createInventoryTransaction(Map<String, dynamic> transaction,
      Map<String, int> deltasByStockId) async {
    final WriteBatch batch = _firestore.batch();

    final txnRef = _transactionsCol.doc();
    batch.set(txnRef, {
      ...transaction,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Apply deltas using atomic increments
    deltasByStockId.forEach((stockId, delta) {
      final stockRef = _stockLevelsCol.doc(stockId);
      batch.set(
          stockRef,
          {
            'quantity': FieldValue.increment(delta),
            'lastUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });

    await batch.commit();
  }

  @override
  Future<Map<String, dynamic>?> getComponent(String id) async {
    final doc = await _componentsCol.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchComponents(
      {int limit = 50, String? startAfterId}) async {
    Query query =
        _componentsCol.orderBy('createdAt', descending: true).limit(limit);
    if (startAfterId != null) {
      final doc = await _componentsCol.doc(startAfterId).get();
      if (doc.exists) query = query.startAfterDocument(doc);
    }
    final snap = await query.get();
    return snap.docs.map((d) {
      final m = d.data() as Map<String, dynamic>;
      m['id'] = d.id;
      return m;
    }).toList();
  }

  @override
  Future<void> upsertComponent(Map<String, dynamic> component) async {
    final id = component['id'] as String?;
    final data = Map<String, dynamic>.from(component);
    data.remove('id');
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (id == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await _componentsCol.add(data);
    } else {
      await _componentsCol.doc(id).set(data, SetOptions(merge: true));
    }
  }
}
