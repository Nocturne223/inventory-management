import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/inventory_providers.dart';

// ...existing imports

class InventoryListPage extends ConsumerStatefulWidget {
  const InventoryListPage({super.key});

  @override
  ConsumerState<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends ConsumerState<InventoryListPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = [
    'All',
    'CPU',
    'RAM',
    'Motherboard',
    'Graphics Card',
    'Storage',
    'Power Supply',
    'Case',
    'Monitor',
    'Keyboard',
    'Mouse',
    'Network',
    'Audio',
    'Other',
  ];

  final List<String> _statuses = [
    'All',
    'Available',
    'Deployed',
    'Maintenance',
    'Damaged',
    'Disposed',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(inventoryRepositoryProvider);
    return Scaffold(
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search components...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
                const SizedBox(height: 12),

                // Category and Status filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((category) {
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statuses.map((status) {
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
              ],
            ),
          ),

          // Components list
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: repo.fetchComponents(limit: 200),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final components = snapshot.data ?? [];
                if (components.isEmpty) {
                  return _buildComponentsList(); // fallback mock
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: components.length,
                  itemBuilder: (context, index) {
                    final component = components[index];
                    return _ComponentListItem(component: component);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-component');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildComponentsList() {
    // Mock data for demonstration
    final mockComponents = List.generate(
        20,
        (index) => {
              'id': 'comp_$index',
              'name': 'Component $index',
              'category': _categories[(index % (_categories.length - 1)) + 1],
              'brand': ['Dell', 'HP', 'Lenovo', 'ASUS', 'Acer'][index % 5],
              'model': 'Model ${index + 1}',
              'serialNumber': 'SN${1000 + index}',
              'assetTag': 'MIT${2000 + index}',
              'status': _statuses[(index % (_statuses.length - 1)) + 1],
              'location': 'Lab ${String.fromCharCode(65 + (index % 5))}',
            });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockComponents.length,
      itemBuilder: (context, index) {
        final component = mockComponents[index];
        return _ComponentListItem(component: component);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filters',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Additional filters will be implemented here',
              style: GoogleFonts.roboto(),
            ),
            const SizedBox(height: 16),
            // Add more filter options here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ComponentListItem extends StatelessWidget {
  final Map<String, dynamic> component;

  const _ComponentListItem({required this.component});

  @override
  Widget build(BuildContext context) {
    final status = component['status'] as String;
    final statusColor = StatusColors.getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ComponentColors.getCategoryColor(component['category'])
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(component['category']),
            color: ComponentColors.getCategoryColor(component['category']),
            size: 24,
          ),
        ),
        title: Text(
          component['name'],
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${component['brand']} ${component['model']}',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'S/N: ${component['serialNumber']} • Asset: ${component['assetTag']}',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (component['location'] != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    component['location'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'deploy',
              child: ListTile(
                leading: Icon(Icons.send),
                title: Text('Deploy'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'qr',
              child: ListTile(
                leading: Icon(Icons.qr_code),
                title: Text('Generate QR'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                Navigator.pushNamed(
                  context,
                  '/component-detail',
                  arguments: component['id'],
                );
                break;
              case 'edit':
                Navigator.pushNamed(
                  context,
                  '/add-component',
                  arguments: {
                    'componentId': component['id'],
                    'category': component['category'],
                  },
                );
                break;
              case 'deploy':
                // Show deployment dialog
                break;
              case 'qr':
                // Generate and show QR code
                break;
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/component-detail',
            arguments: component['id'],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'CPU':
        return Icons.memory;
      case 'RAM':
        return Icons.storage;
      case 'Motherboard':
        return Icons.developer_board;
      case 'Graphics Card':
        return Icons.videocam;
      case 'Storage':
        return Icons.storage;
      case 'Power Supply':
        return Icons.power;
      case 'Case':
        return Icons.computer;
      case 'Monitor':
        return Icons.monitor;
      case 'Keyboard':
        return Icons.keyboard;
      case 'Mouse':
        return Icons.mouse;
      case 'Network':
        return Icons.router;
      case 'Audio':
        return Icons.headphones;
      default:
        return Icons.devices;
    }
  }
}
