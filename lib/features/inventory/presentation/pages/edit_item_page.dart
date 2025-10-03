import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/inventory_providers.dart' as inventory_providers;
import '../../../deployment/providers/deployment_providers.dart'
    show dataServiceProvider;
import '../../../../core/models/inventory_models.dart';

class EditItemPage extends ConsumerStatefulWidget {
  final InventoryItem item;

  const EditItemPage({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _serialController;
  late final TextEditingController _priceController;

  String? _selectedCategory;
  String? _selectedStatus;
  late String _selectedDepartment;
  late String _selectedLocation;
  late DateTime _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _brandController = TextEditingController(text: widget.item.brand);
    _modelController = TextEditingController(text: widget.item.model);
    _serialController = TextEditingController(text: widget.item.serialNumber);
    _priceController =
        TextEditingController(text: widget.item.price.toString());

    // Defer initial value setting until build when we have access to providers
    _selectedDepartment = widget.item.departmentId;
    _selectedLocation = widget.item.locationId;
    _purchaseDate = widget.item.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataServiceProvider);

      final updatedItem = widget.item.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        serialNumber: _serialController.text.trim(),
        category: _selectedCategory ?? widget.item.category,
        status: _selectedStatus ?? widget.item.status,
        departmentId: _selectedDepartment,
        locationId: _selectedLocation,
        price: double.tryParse(_priceController.text) ?? 0.0,
        purchaseDate: _purchaseDate,
        updatedAt: DateTime.now(),
      );

      await dataService.updateItemData(widget.item.id, updatedItem.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(inventory_providers.categoriesProvider);
    final statuses = ref.watch(inventory_providers.statusesProvider);
    final departments = ref.watch(inventory_providers.departmentsProvider);
    final locations = ref.watch(inventory_providers.locationsProvider);

    // Filter out 'All' from categories and statuses for edit form
    final editCategories = categories.where((cat) => cat != 'All').toList();
    final editStatuses = statuses.where((status) => status != 'All').toList();

    // If categories or statuses are empty (still loading), return loading state
    if (editCategories.isEmpty || editStatuses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Item',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Item',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateItem,
            child: Text(
              'Update',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _SectionHeader(title: 'Basic Information'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category and Status
            _SectionHeader(title: 'Category & Status'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: () {
                      // Initialize _selectedCategory if not set yet
                      if (_selectedCategory == null) {
                        _selectedCategory =
                            editCategories.contains(widget.item.category)
                                ? widget.item.category
                                : (editCategories.isNotEmpty
                                    ? editCategories.first
                                    : null);
                      }
                      // Return value only if it's in the list
                      return editCategories.contains(_selectedCategory)
                          ? _selectedCategory
                          : null;
                    }(),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: editCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: () {
                      // Initialize _selectedStatus if not set yet
                      if (_selectedStatus == null) {
                        _selectedStatus =
                            editStatuses.contains(widget.item.status)
                                ? widget.item.status
                                : (editStatuses.isNotEmpty
                                    ? editStatuses.first
                                    : null);
                      }
                      // Return value only if it's in the list
                      return editStatuses.contains(_selectedStatus)
                          ? _selectedStatus
                          : null;
                    }(),
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: editStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Details
            _SectionHeader(title: 'Product Details'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Location & Assignment
            _SectionHeader(title: 'Location & Assignment'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: departments.when(
                    data: (depts) {
                      // Check if selected department exists in the list
                      final validSelection =
                          depts.any((dept) => dept.id == _selectedDepartment);
                      return DropdownButtonFormField<String>(
                        value: validSelection && _selectedDepartment.isNotEmpty
                            ? _selectedDepartment
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: depts.map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child: Text(dept.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value ?? '';
                          });
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading departments'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: locations.when(
                    data: (locs) {
                      // Check if selected location exists in the list
                      final validSelection =
                          locs.any((loc) => loc.id == _selectedLocation);
                      return DropdownButtonFormField<String>(
                        value: validSelection && _selectedLocation.isNotEmpty
                            ? _selectedLocation
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        items: locs.map((loc) {
                          return DropdownMenuItem(
                            value: loc.id,
                            child: Text(loc.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value ?? '';
                          });
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading locations'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Financial Information
            _SectionHeader(title: 'Financial Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _purchaseDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _purchaseDate = selectedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Purchase Date: ${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
