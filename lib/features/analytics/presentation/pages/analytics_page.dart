import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics & Reports',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comprehensive analytics and reporting features will be implemented here.',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Placeholder cards for different analytics sections
            _buildAnalyticsCard(
              'Inventory Overview',
              'Total components, distribution by category and status',
              Icons.pie_chart,
            ),
            const SizedBox(height: 16),
            _buildAnalyticsCard(
              'Deployment Analytics',
              'Usage patterns, deployment history, and utilization rates',
              Icons.trending_up,
            ),
            const SizedBox(height: 16),
            _buildAnalyticsCard(
              'Maintenance Reports',
              'Maintenance schedules, costs, and component lifecycle',
              Icons.build,
            ),
            const SizedBox(height: 16),
            _buildAnalyticsCard(
              'Laboratory Utilization',
              'Lab occupancy, resource allocation, and efficiency metrics',
              Icons.science,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
