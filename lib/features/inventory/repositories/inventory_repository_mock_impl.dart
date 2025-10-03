import '../interfaces/inventory_repository.dart';

class MockInventoryRepository implements InventoryRepository {
  final Map<String, Map<String, dynamic>> _components = {};
  final Map<String, int> _stockLevels =
      {}; // key: "{itemId}__{locationId}" -> qty
  final List<Map<String, dynamic>> _transactions = [];

  @override
  Future<void> createInventoryTransaction(Map<String, dynamic> transaction,
      Map<String, int> deltasByStockId) async {
    // simple atomic behavior: apply deltas then append transaction
    deltasByStockId.forEach((stockId, delta) {
      final cur = _stockLevels[stockId] ?? 0;
      _stockLevels[stockId] = cur + delta;
    });
    _transactions.add(transaction);
    return;
  }

  @override
  Future<Map<String, dynamic>?> getComponent(String id) async {
    return _components[id];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchComponents(
      {int limit = 50, String? startAfterId}) async {
    // Return a simple list of components
    return _components.values.take(limit).toList();
  }

  @override
  Future<void> upsertComponent(Map<String, dynamic> component) async {
    final id = component['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString();
    component['id'] = id;
    _components[id] = Map<String, dynamic>.from(component);
    return;
  }
}
