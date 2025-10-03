abstract class InventoryRepository {
  /// Returns a paginated list of components (mock uses simple list)
  Future<List<Map<String, dynamic>>> fetchComponents(
      {int limit = 50, String? startAfterId});

  /// Create or update a component document
  Future<void> upsertComponent(Map<String, dynamic> component);

  /// Create an inventory transaction and update stock_levels atomically where possible
  Future<void> createInventoryTransaction(
      Map<String, dynamic> transaction, Map<String, int> deltasByStockId);

  /// Get a single component by id
  Future<Map<String, dynamic>?> getComponent(String id);
}
