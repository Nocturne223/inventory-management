import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/inventory_service.dart';
import '../../../core/models/inventory_models.dart';

// Service Provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

// Inventory Items Providers
final inventoryItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getInventoryItems();
});

final inventoryItemProvider =
    FutureProvider.family<InventoryItem?, String>((ref, id) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getInventoryItem(id);
});

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String>((ref) => 'All');
final statusFilterProvider = StateProvider<String>((ref) => 'All');
final departmentFilterProvider = StateProvider<String>((ref) => 'All');

// Filtered Items Provider
final filteredInventoryItemsProvider =
    Provider<AsyncValue<List<InventoryItem>>>((ref) {
  final itemsAsync = ref.watch(inventoryItemsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final departmentFilter = ref.watch(departmentFilterProvider);

  return itemsAsync.whenData((items) {
    var filteredItems = items;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.model.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.serialNumber.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != 'All') {
      filteredItems = filteredItems
          .where((item) => item.category == categoryFilter)
          .toList();
    }

    // Apply status filter
    if (statusFilter != 'All') {
      filteredItems = filteredItems
          .where(
              (item) => item.status.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }

    // Apply department filter
    if (departmentFilter != 'All') {
      filteredItems = filteredItems
          .where((item) => item.departmentId == departmentFilter)
          .toList();
    }

    return filteredItems;
  });
});

// Departments Providers
final departmentsProvider = StreamProvider<List<Department>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getDepartments();
});

final departmentProvider =
    FutureProvider.family<Department?, String>((ref, id) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getDepartment(id);
});

// Locations Providers
final locationsProvider = StreamProvider<List<Location>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getLocations();
});

final locationProvider = FutureProvider.family<Location?, String>((ref, id) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getLocation(id);
});

// Statistics Provider
final inventoryStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getInventoryStats();
});

// Category Distribution Provider for Pie Chart
final categoryDistributionProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getCategoryDistributionStream();
});

// Distribution for only currently deployed items
final deployedCategoryDistributionProvider =
    StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getDeployedCategoryDistributionStream();
});

// Additional context if needed

// Categories and Statuses Providers
final categoriesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return ['All'] + service.getCategories();
});

final statusesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return ['All'] + service.getStatuses();
});

// Form State Providers for Add/Edit Item
final itemFormProvider =
    StateNotifierProvider<ItemFormNotifier, ItemFormState>((ref) {
  return ItemFormNotifier();
});

class ItemFormState {
  final String name;
  final String description;
  final String category;
  final String brand;
  final String model;
  final String serialNumber;
  final String status;
  final double price;
  final DateTime purchaseDate;
  final String? warrantyExpiry;
  final String locationId;
  final String departmentId;
  final Map<String, dynamic> specifications;
  final bool isLoading;
  final String? error;

  ItemFormState({
    this.name = '',
    this.description = '',
    this.category = '',
    this.brand = '',
    this.model = '',
    this.serialNumber = '',
    this.status = 'available',
    this.price = 0.0,
    DateTime? purchaseDate,
    this.warrantyExpiry,
    this.locationId = '',
    this.departmentId = '',
    this.specifications = const {},
    this.isLoading = false,
    this.error,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  ItemFormState copyWith({
    String? name,
    String? description,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? status,
    double? price,
    DateTime? purchaseDate,
    String? warrantyExpiry,
    String? locationId,
    String? departmentId,
    Map<String, dynamic>? specifications,
    bool? isLoading,
    String? error,
  }) {
    return ItemFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      locationId: locationId ?? this.locationId,
      departmentId: departmentId ?? this.departmentId,
      specifications: specifications ?? this.specifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ItemFormNotifier extends StateNotifier<ItemFormState> {
  ItemFormNotifier() : super(ItemFormState());

  void updateName(String name) => state = state.copyWith(name: name);
  void updateDescription(String description) =>
      state = state.copyWith(description: description);
  void updateCategory(String category) =>
      state = state.copyWith(category: category);
  void updateBrand(String brand) => state = state.copyWith(brand: brand);
  void updateModel(String model) => state = state.copyWith(model: model);
  void updateSerialNumber(String serialNumber) =>
      state = state.copyWith(serialNumber: serialNumber);
  void updateStatus(String status) => state = state.copyWith(status: status);
  void updatePrice(double price) => state = state.copyWith(price: price);
  void updatePurchaseDate(DateTime date) =>
      state = state.copyWith(purchaseDate: date);
  void updateWarrantyExpiry(String? warranty) =>
      state = state.copyWith(warrantyExpiry: warranty);
  void updateLocationId(String locationId) =>
      state = state.copyWith(locationId: locationId);
  void updateDepartmentId(String departmentId) =>
      state = state.copyWith(departmentId: departmentId);
  void updateSpecifications(Map<String, dynamic> specs) =>
      state = state.copyWith(specifications: specs);

  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
  void setError(String? error) => state = state.copyWith(error: error);

  void reset() {
    state = ItemFormState();
  }

  void loadItem(InventoryItem item) {
    state = ItemFormState(
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
      specifications: item.specifications ?? {},
    );
  }
}
