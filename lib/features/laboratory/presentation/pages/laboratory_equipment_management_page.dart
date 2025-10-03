import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/inventory_models.dart';
import '../../../../core/models/deployment_models.dart';
import '../../../../providers/laboratory_occupancy_providers.dart';
import '../../../../services/laboratory_occupancy_service.dart';
import '../../../deployment/providers/deployment_providers.dart';
import '../../../inventory/providers/inventory_providers.dart';

class LaboratoryEquipmentManagementPage extends ConsumerStatefulWidget {
  final Location laboratory;

  const LaboratoryEquipmentManagementPage({
    super.key,
    required this.laboratory,
  });

  @override
  ConsumerState<LaboratoryEquipmentManagementPage> createState() =>
      _LaboratoryEquipmentManagementPageState();
}

class _LaboratoryEquipmentManagementPageState
    extends ConsumerState<LaboratoryEquipmentManagementPage> {
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final occupancyAsync =
        ref.watch(laboratoryOccupancyProvider(widget.laboratory.id));
    final deploymentsAsync = ref.watch(deploymentsProvider);
    final itemsAsync = ref.watch(inventoryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipment Management',
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              widget.laboratory.name,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _showAddEquipmentDialog(context),
            tooltip: 'Deploy Equipment',
          ),
        ],
      ),
      body: Column(
        children: [
          // Occupancy Summary
          occupancyAsync.when(
            data: (occupancyData) => _buildOccupancySummary(occupancyData),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Container(),
          ),

          // Search and Filter Bar
          _buildSearchAndFilter(),

          // Equipment List
          Expanded(
            child: deploymentsAsync.when(
              data: (deployments) => itemsAsync.when(
                data: (items) => _buildEquipmentList(deployments, items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    _buildErrorMessage('Error loading items: $error'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorMessage('Error loading deployments: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancySummary(LaboratoryOccupancyData occupancyData) {
    final percentage = (occupancyData.occupancyRate * 100).toInt();
    Color statusColor = Colors.green;

    if (occupancyData.occupancyRate > 0.8) {
      statusColor = Colors.red;
    } else if (occupancyData.occupancyRate > 0.5) {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laboratory Occupancy',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${occupancyData.occupiedStations} of ${occupancyData.capacity} stations occupied ($percentage%)',
                  style: GoogleFonts.roboto(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$percentage%',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _filterStatus,
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Equipment')),
              DropdownMenuItem(value: 'active', child: Text('Active Only')),
              DropdownMenuItem(
                  value: 'available', child: Text('Available Items')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList(
      List<Deployment> deployments, List<InventoryItem> items) {
    // Filter deployments for this laboratory
    var labDeployments =
        deployments.where((d) => d.locationId == widget.laboratory.id).toList();

    // Apply status filter
    if (_filterStatus == 'active') {
      labDeployments =
          labDeployments.where((d) => d.status == 'active').toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      labDeployments = labDeployments
          .where((d) =>
              d.itemName.toLowerCase().contains(_searchQuery) ||
              d.assignedTo.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Get available items if showing available filter
    List<InventoryItem> availableItems = [];
    if (_filterStatus == 'available') {
      final deployedItemIds = deployments
          .where((d) => d.status == 'active')
          .map((d) => d.itemId)
          .toSet();

      availableItems = items
          .where((item) =>
              !deployedItemIds.contains(item.id) &&
              item.status == 'available' &&
              (_searchQuery.isEmpty ||
                  item.name.toLowerCase().contains(_searchQuery)))
          .toList();
    }

    if (_filterStatus == 'available' && availableItems.isEmpty) {
      return _buildEmptyState('No available equipment found');
    }

    if (labDeployments.isEmpty && _filterStatus != 'available') {
      return _buildEmptyState('No equipment deployed to this laboratory');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_filterStatus == 'available') ...[
          Text(
            'Available Equipment (${availableItems.length} items)',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...availableItems.map((item) => _buildAvailableEquipmentItem(item)),
        ] else ...[
          Text(
            'Deployed Equipment (${labDeployments.length} items)',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...labDeployments
              .map((deployment) => _buildDeployedEquipmentItem(deployment)),
        ],
      ],
    );
  }

  Widget _buildDeployedEquipmentItem(Deployment deployment) {
    Color statusColor = Colors.green;
    if (deployment.status == 'overdue') statusColor = Colors.red;
    if (deployment.status == 'pending-return') statusColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.computer, color: statusColor, size: 24),
        ),
        title: Text(
          deployment.itemName,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned to: ${deployment.assignedTo}'),
            Text('Deployed: ${_formatDate(deployment.deployedAt)}'),
            if (deployment.expectedReturnDate != null)
              Text(
                  'Expected return: ${_formatDate(deployment.expectedReturnDate!)}'),
          ],
        ),
        // PopupMenuButton commented out temporarily - Equipment management actions
        /*
        trailing: PopupMenuButton<String>(
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
              value: 'return',
              child: ListTile(
                leading: Icon(Icons.keyboard_return, color: Colors.orange),
                title: Text('Return Equipment'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (deployment.status == 'active')
              const PopupMenuItem(
                value: 'reassign',
                child: ListTile(
                  leading: Icon(Icons.swap_horiz),
                  title: Text('Reassign'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
          onSelected: (value) => _handleDeploymentAction(value, deployment),
        ),
        */
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAvailableEquipmentItem(InventoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.inventory, color: Colors.blue, size: 24),
        ),
        title: Text(
          item.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${item.category}'),
            if (item.model.isNotEmpty) Text('Model: ${item.model}'),
            Text('Serial: ${item.serialNumber}'),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _deployEquipment(item),
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Deploy'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          if (_filterStatus != 'available')
            ElevatedButton.icon(
              onPressed: () => _showAddEquipmentDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Deploy Equipment'),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.roboto(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deploy Equipment'),
        content: Text(
            'Equipment deployment functionality will be integrated with the deployment system.\n\nThis would allow you to:\n• Select available equipment\n• Assign to users\n• Set return dates\n• Track deployment status'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // _handleDeploymentAction method commented out along with popup menu
  /*
  void _handleDeploymentAction(String action, Deployment deployment) {
    switch (action) {
      case 'view':
        // Navigate to deployment detail view
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing details for ${deployment.itemName}'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'return':
        _returnEquipment(deployment);
        break;
      case 'reassign':
        _reassignEquipment(deployment);
        break;
    }
  }
  */

  // _returnEquipment and _reassignEquipment methods commented out along with popup menu
  /*
  void _returnEquipment(Deployment deployment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Equipment'),
        content: Text(
            'Mark ${deployment.itemName} as returned from ${widget.laboratory.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would call the return equipment service
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${deployment.itemName} marked as returned'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _reassignEquipment(Deployment deployment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reassigning ${deployment.itemName}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  */

  void _deployEquipment(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deploy ${item.name}'),
        content: Text(
            'Deploy ${item.name} to ${widget.laboratory.name}?\n\nThis will move the equipment to this laboratory and mark it as active.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would call the deployment service
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${item.name} deployed to ${widget.laboratory.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Deploy'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
