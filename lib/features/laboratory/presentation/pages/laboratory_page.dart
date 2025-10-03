import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/inventory_models.dart';
import '../../../../services/firestore_data_service.dart' as firestore_service;
import '../../../../providers/laboratory_occupancy_providers.dart';
import '../../../../services/laboratory_occupancy_service.dart';
import '../../../deployment/providers/deployment_providers.dart';
import 'add_edit_laboratory_page.dart';
import 'laboratory_detail_page.dart';
import 'laboratory_equipment_management_page.dart';

class LaboratoryPage extends ConsumerWidget {
  const LaboratoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laboratory Management',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manage computer laboratories and their equipment allocation.',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Real laboratory data from Firestore
            locationsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading laboratories: $error',
                      style: GoogleFonts.roboto(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (locations) {
                if (locations.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.science_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No laboratories found',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first laboratory to get started',
                          style: GoogleFonts.roboto(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: locations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final location = entry.value;
                    final colors = [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.teal,
                      Colors.indigo,
                    ];
                    final color = colors[index % colors.length];

                    return Column(
                      children: [
                        _buildLaboratoryCard(
                          location,
                          color,
                          context,
                          ref,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditLaboratoryPage(),
            ),
          );

          // Refresh the list if a laboratory was added
          if (result == true) {
            // The provider will automatically refresh the data
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLaboratoryCard(
    Location location,
    Color color,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final occupancyAsync =
            ref.watch(laboratoryOccupancyProvider(location.id));

        return occupancyAsync.when(
          data: (occupancyData) => _buildLaboratoryCardContent(
            location,
            occupancyData,
            color,
            context,
            ref,
          ),
          loading: () => _buildLoadingCard(location, color),
          error: (error, stack) => _buildErrorCard(location, color, error),
        );
      },
    );
  }

  Widget _buildLaboratoryCardContent(
    Location location,
    LaboratoryOccupancyData occupancyData,
    Color color,
    BuildContext context,
    WidgetRef ref,
  ) {
    final capacity = occupancyData.capacity;
    final occupied = occupancyData.occupiedStations;
    final occupancyRate = occupancyData.occupancyRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.science, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${location.building} - ${location.room}',
                        style: GoogleFonts.roboto(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (location.description != null)
                        Text(
                          location.description!,
                          style: GoogleFonts.roboto(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
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
                      value: 'equipment',
                      child: ListTile(
                        leading: Icon(Icons.inventory),
                        title: Text('Manage Equipment'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'view':
                        // Navigate to laboratory detail view
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LaboratoryDetailPage(
                              laboratory: location,
                            ),
                          ),
                        );

                        // Refresh the list if laboratory was updated from detail page
                        if (result == true) {
                          // The provider will automatically refresh the data
                        }
                        break;
                      case 'edit':
                        // Navigate to edit laboratory form
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditLaboratoryPage(
                              laboratory: location,
                              isEditing: true,
                            ),
                          ),
                        );

                        // Refresh the list if laboratory was updated
                        if (result == true) {
                          // The provider will automatically refresh the data
                        }
                        break;
                      case 'equipment':
                        // Navigate to equipment management
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LaboratoryEquipmentManagementPage(
                              laboratory: location,
                            ),
                          ),
                        );
                        break;
                      case 'delete':
                        // Show delete confirmation dialog
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Laboratory'),
                            content: Text(
                              'Are you sure you want to delete "${location.name}"? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          try {
                            final service = ref.read(
                                firestore_service.firestoreDataServiceProvider);
                            await service.deleteLocation(location.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Laboratory deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error deleting laboratory: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Occupancy indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Occupancy: $occupied / $capacity',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: occupancyRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          occupancyRate > 0.8
                              ? Colors.red
                              : occupancyRate > 0.6
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: occupancyRate > 0.8
                        ? Colors.red.withOpacity(0.1)
                        : occupancyRate > 0.6
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: occupancyRate > 0.8
                          ? Colors.red.withOpacity(0.3)
                          : occupancyRate > 0.6
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${(occupancyRate * 100).toInt()}%',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: occupancyRate > 0.8
                          ? Colors.red
                          : occupancyRate > 0.6
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(Location location, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.science, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (location.description?.isNotEmpty == true)
                        Text(
                          location.description!,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Location location, Color color, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.science, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (location.description?.isNotEmpty == true)
                        Text(
                          location.description!,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading occupancy data',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
