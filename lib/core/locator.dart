import 'package:get_it/get_it.dart';
import '../features/inventory/interfaces/inventory_repository.dart';
import '../features/inventory/repositories/inventory_repository_mock_impl.dart';

final GetIt locator = GetIt.instance;

void setupLocator({bool useMocks = true}) {
  if (!locator.isRegistered<InventoryRepository>()) {
    if (useMocks) {
      locator.registerLazySingleton<InventoryRepository>(
          () => MockInventoryRepository());
    } else {
      // Placeholder: register Firestore implementation when ready
      locator.registerLazySingleton<InventoryRepository>(
          () => MockInventoryRepository());
    }
  }
}
