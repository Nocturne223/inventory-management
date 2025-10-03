import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/inventory_models.dart';
import '../../../../core/models/deployment_models.dart';
import '../../../../providers/laboratory_occupancy_providers.dart';
import '../../../../services/laboratory_occupancy_service.dart';
import '../../../deployment/providers/deployment_providers.dart';
import 'add_edit_laboratory_page.dart';
import 'laboratory_equipment_management_page.dart';

class LaboratoryDetailPage extends ConsumerWidget {
  final Location laboratory;

  const LaboratoryDetailPage({
    super.key,
    required this.laboratory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyAsync =
        ref.watch(laboratoryOccupancyProvider(laboratory.id));
    final deploymentsAsync = ref.watch(deploymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          laboratory.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLaboratory(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Laboratory Information Card
            _buildLaboratoryInfoCard(),
            const SizedBox(height: 16),

            // Occupancy Status Card
            occupancyAsync.when(
              data: (occupancyData) => _buildOccupancyCard(occupancyData),
              loading: () => _buildLoadingCard('Loading occupancy data...'),
              error: (error, stack) =>
                  _buildErrorCard('Error loading occupancy data'),
            ),
            const SizedBox(height: 16),

            // Equipment List
            _buildEquipmentSection(deploymentsAsync),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEquipmentManagement(context),
        icon: const Icon(Icons.inventory),
        label: const Text('Manage Equipment'),
      ),
    );
  }

  Widget _buildLaboratoryInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.science, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laboratory.name,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (laboratory.description?.isNotEmpty == true)
                        Text(
                          laboratory.description!,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Building', laboratory.building),
            _buildInfoRow('Room', laboratory.room),
            _buildInfoRow('Capacity', '${laboratory.capacity} stations'),
            _buildInfoRow('Created', _formatDate(laboratory.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(LaboratoryOccupancyData occupancyData) {
    final percentage = (occupancyData.occupancyRate * 100).toInt();
    Color statusColor = Colors.green;
    String statusText = 'Available';

    if (occupancyData.occupancyRate > 0.8) {
      statusColor = Colors.red;
      statusText = 'High Occupancy';
    } else if (occupancyData.occupancyRate > 0.5) {
      statusColor = Colors.orange;
      statusText = 'Moderate Occupancy';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Occupancy Status',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$percentage%',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        statusText,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: occupancyData.occupancyRate.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Occupied',
                    '${occupancyData.occupiedStations}',
                    Icons.computer,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Available',
                    '${occupancyData.availableStations}',
                    Icons.computer_outlined,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Capacity',
                    '${occupancyData.capacity}',
                    Icons.storage,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(AsyncValue<List<Deployment>> deploymentsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Deployed Equipment',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            deploymentsAsync.when(
              data: (deployments) {
                final labDeployments = deployments
                    .where((d) =>
                        d.locationId == laboratory.id && d.status == 'active')
                    .toList();

                if (labDeployments.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No equipment currently deployed',
                          style: GoogleFonts.roboto(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: labDeployments
                      .map((deployment) => _buildEquipmentItem(deployment))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading equipment: $error',
                  style: GoogleFonts.roboto(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(Deployment deployment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.computer, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deployment.itemName,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Assigned to: ${deployment.assignedTo}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Deployed: ${_formatDate(deployment.deployedAt)}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deployment.status.toUpperCase(),
              style: GoogleFonts.roboto(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message, style: GoogleFonts.roboto()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(message, style: GoogleFonts.roboto(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editLaboratory(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLaboratoryPage(
          laboratory: laboratory,
          isEditing: true,
        ),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(
          context, true); // Return to laboratory list with refresh signal
    }
  }

  void _navigateToEquipmentManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaboratoryEquipmentManagementPage(
          laboratory: laboratory,
        ),
      ),
    );
  }
}
