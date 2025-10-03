import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/locator.dart';
import '../interfaces/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return locator<InventoryRepository>();
});
