import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Management',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Schedule and track maintenance activities for IT components.',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Maintenance overview cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Scheduled',
                    '12',
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    'In Progress',
                    '5',
                    Icons.build,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Completed',
                    '28',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    'Overdue',
                    '3',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent maintenance activities
            Text(
              'Recent Activities',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Mock maintenance records
            _buildMaintenanceItem(
              'Dell OptiPlex 7090 - RAM Upgrade',
              'Scheduled for today',
              'Computer Science Lab A',
              'scheduled',
              Icons.memory,
            ),
            const SizedBox(height: 12),
            _buildMaintenanceItem(
              'HP LaserJet Pro - Toner Replacement',
              'In progress - Started 2 hours ago',
              'Engineering Lab B',
              'inProgress',
              Icons.print,
            ),
            const SizedBox(height: 12),
            _buildMaintenanceItem(
              'Network Switch - Port Repair',
              'Completed yesterday',
              'IT Support Center',
              'completed',
              Icons.router,
            ),
            const SizedBox(height: 12),
            _buildMaintenanceItem(
              'MacBook Pro - Battery Replacement',
              'Overdue by 2 days',
              'Research Lab',
              'overdue',
              Icons.laptop_mac,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to schedule maintenance form
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(
    String title,
    String status,
    String location,
    String statusType,
    IconData icon,
  ) {
    Color statusColor;
    switch (statusType) {
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'inProgress':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'overdue':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: statusColor, size: 24),
        ),
        title: Text(
          title,
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
              status,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
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
            if (statusType == 'scheduled')
              const PopupMenuItem(
                value: 'start',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Start Maintenance'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (statusType == 'inProgress')
              const PopupMenuItem(
                value: 'complete',
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Mark Complete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
          onSelected: (value) {
            // Handle menu actions
          },
        ),
      ),
    );
  }
}
