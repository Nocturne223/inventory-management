import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/inventory_providers.dart';
import '../../../../core/models/inventory_models.dart';
import '../../../deployment/providers/deployment_providers.dart'
    show dataServiceProvider;
import 'item_detail_page.dart';

class InventoryListPage extends ConsumerStatefulWidget {
  final bool showAppBar;

  const InventoryListPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  ConsumerState<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends ConsumerState<InventoryListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = ref.watch(filteredInventoryItemsProvider);
    final categories = ref.watch(categoriesProvider);
    final statuses = ref.watch(statusesProvider);
    final departments = ref.watch(departmentsProvider);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'Inventory Management',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            )
          : null,
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category Filter
                      _FilterDropdown(
                        label: 'Category',
                        value: ref.watch(categoryFilterProvider),
                        items: categories,
                        onChanged: (value) {
                          ref.read(categoryFilterProvider.notifier).state =
                              value!;
                        },
                      ),
                      const SizedBox(width: 12),

                      // Status Filter
                      _FilterDropdown(
                        label: 'Status',
                        value: ref.watch(statusFilterProvider),
                        items: statuses,
                        onChanged: (value) {
                          ref.read(statusFilterProvider.notifier).state =
                              value!;
                        },
                      ),
                      const SizedBox(width: 12),

                      // Department Filter
                      departments.when(
                        data: (deptList) {
                          // Ensure unique department names to prevent dropdown errors
                          final uniqueDeptNames = <String>{'All'};
                          for (final dept in deptList) {
                            uniqueDeptNames.add(dept.name);
                          }
                          final deptNames = uniqueDeptNames.toList();

                          final currentFilter =
                              ref.watch(departmentFilterProvider);

                          // Determine the display value for the dropdown
                          String displayValue;
                          if (currentFilter == 'All') {
                            displayValue = 'All';
                          } else {
                            // Try to find department by ID first, then by name
                            final deptById =
                                deptList.where((d) => d.id == currentFilter);
                            if (deptById.isNotEmpty) {
                              displayValue = deptById.first.name;
                            } else {
                              // Check if the current filter is already a name
                              displayValue = deptNames.contains(currentFilter)
                                  ? currentFilter
                                  : 'All';
                            }
                          }

                          return _FilterDropdown(
                            label: 'Department',
                            value: displayValue,
                            items: deptNames,
                            onChanged: (value) {
                              if (value == 'All') {
                                ref
                                    .read(departmentFilterProvider.notifier)
                                    .state = 'All';
                              } else {
                                final matchingDepts =
                                    deptList.where((d) => d.name == value);
                                if (matchingDepts.isNotEmpty) {
                                  ref
                                      .read(departmentFilterProvider.notifier)
                                      .state = matchingDepts.first.id;
                                }
                              }
                            },
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: filteredItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _InventoryItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailPage(itemId: item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading items',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isDense: true,
        ),
      ),
    );
  }
}

class _InventoryItemCard extends ConsumerWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const _InventoryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final department = ref.watch(departmentProvider(item.departmentId));
    final location = ref.watch(locationProvider(item.locationId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.brand} ${item.model}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _StatusChip(status: item.status),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              Navigator.pushNamed(
                                context,
                                '/inventory/edit',
                                arguments: item,
                              );
                              break;
                            case 'delete':
                              _showDeleteDialog(context, ref, item);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.category_outlined,
                      label: item.category,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.qr_code,
                      label: item.serialNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: department.when(
                      data: (dept) => _InfoItem(
                        icon: Icons.business_outlined,
                        label: dept?.name ?? 'Unknown Department',
                      ),
                      loading: () => _InfoItem(
                        icon: Icons.business_outlined,
                        label: 'Loading...',
                      ),
                      error: (_, __) => _InfoItem(
                        icon: Icons.business_outlined,
                        label: 'Unknown Department',
                      ),
                    ),
                  ),
                  Expanded(
                    child: location.when(
                      data: (loc) => _InfoItem(
                        icon: Icons.location_on_outlined,
                        label: loc?.name ?? 'Unknown Location',
                      ),
                      loading: () => _InfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Loading...',
                      ),
                      error: (_, __) => _InfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Unknown Location',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final dataService = ref.read(dataServiceProvider);
                await dataService.deleteItem(item.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting item: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'available':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'in-use':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'maintenance':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'retired':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
