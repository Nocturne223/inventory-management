import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class ComponentDetailPage extends StatelessWidget {
  final String componentId;

  const ComponentDetailPage({
    super.key,
    required this.componentId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock component data - in real implementation, fetch from database
    final component = _getMockComponent();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          component['name'],
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-component',
                arguments: {
                  'componentId': componentId,
                  'category': component['category'],
                },
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'deploy',
                child: ListTile(
                  leading: Icon(Icons.send),
                  title: Text('Deploy'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'maintenance',
                child: ListTile(
                  leading: Icon(Icons.build),
                  title: Text('Schedule Maintenance'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'qr',
                child: ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text('Generate QR Code'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'deploy':
                  _showDeploymentDialog(context);
                  break;
                case 'maintenance':
                  _showMaintenanceDialog(context);
                  break;
                case 'qr':
                  _showQRDialog(context, component);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Component header with image and basic info
            _buildComponentHeader(component),
            const SizedBox(height: 24),

            // Status and location info
            _buildStatusLocationCard(component),
            const SizedBox(height: 16),

            // Basic information
            _buildInfoCard('Basic Information', [
              _buildInfoRow('Category', component['category']),
              _buildInfoRow('Brand', component['brand']),
              _buildInfoRow('Model', component['model']),
              _buildInfoRow('Serial Number', component['serialNumber']),
              _buildInfoRow('Asset Tag', component['assetTag']),
            ]),
            const SizedBox(height: 16),

            // Financial information
            _buildInfoCard('Financial Information', [
              _buildInfoRow('Acquisition Date', component['acquisitionDate']),
              _buildInfoRow('Acquisition Cost', component['acquisitionCost']),
              _buildInfoRow('Warranty Expiry', component['warrantyExpiry']),
              _buildInfoRow('Current Value', component['currentValue']),
            ]),
            const SizedBox(height: 16),

            // Specifications
            _buildSpecificationsCard(component['specifications']),
            const SizedBox(height: 16),

            // Deployment history
            _buildDeploymentHistoryCard(),
            const SizedBox(height: 16),

            // Maintenance history
            _buildMaintenanceHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentHeader(Map<String, dynamic> component) {
    final status = component['status'] as String;
    final statusColor = StatusColors.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ComponentColors.getCategoryColor(component['category'])
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ComponentColors.getCategoryColor(component['category'])
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Component image placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ComponentColors.getCategoryColor(component['category'])
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(component['category']),
              size: 40,
              color: ComponentColors.getCategoryColor(component['category']),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component['name'],
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${component['brand']} ${component['model']}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLocationCard(Map<String, dynamic> component) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            'Current Location',
            component['location'] ?? 'Not assigned',
            Icons.location_on,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniCard(
            'Assigned To',
            component['assignedTo'] ?? 'Available',
            Icons.person,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard(Map<String, dynamic> specs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...specs.entries.map((entry) => _buildInfoRow(
                  entry.key,
                  entry.value.toString(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeploymentHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deployment History',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show full deployment history
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              'Computer Science Lab A',
              'Dec 15, 2023 - Present',
              'Active deployment',
              Icons.computer,
              Colors.green,
            ),
            _buildHistoryItem(
              'Engineering Lab B',
              'Sep 10, 2023 - Dec 14, 2023',
              'Returned after semester',
              Icons.history,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Maintenance History',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show full maintenance history
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              'RAM Upgrade',
              'Nov 20, 2023',
              'Upgraded from 8GB to 16GB',
              Icons.memory,
              Colors.orange,
            ),
            _buildHistoryItem(
              'System Cleaning',
              'Oct 15, 2023',
              'Routine maintenance completed',
              Icons.cleaning_services,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String date,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Map<String, dynamic> _getMockComponent() {
    return {
      'id': componentId,
      'name': 'Dell OptiPlex 7090',
      'category': 'CPU',
      'brand': 'Dell',
      'model': 'OptiPlex 7090',
      'serialNumber': 'SN123456789',
      'assetTag': 'MIT2023001',
      'status': 'Deployed',
      'location': 'Computer Science Lab A',
      'assignedTo': 'John Smith',
      'acquisitionDate': '15/01/2023',
      'acquisitionCost': '\$1,299.00',
      'warrantyExpiry': '15/01/2026',
      'currentValue': '\$999.00',
      'specifications': {
        'Processor': 'Intel Core i7-11700',
        'RAM': '16GB DDR4',
        'Storage': '512GB SSD',
        'Graphics': 'Intel UHD Graphics 750',
        'Operating System': 'Windows 11 Pro',
      },
    };
  }

  void _showDeploymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deploy Component',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
        content: const Text(
            'Deploy component functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Deploy'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Maintenance',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
        content: const Text(
            'Schedule maintenance functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context, Map<String, dynamic> component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(
            data: 'MIT-${component['assetTag']}-${component['serialNumber']}',
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save or share QR code
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Component',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
        content: const Text(
            'Are you sure you want to delete this component? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Component deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
