import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeploymentPage extends StatelessWidget {
  const DeploymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deployment Management',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manage component deployments to laboratories and track usage.',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Placeholder cards for deployment sections
            _buildDeploymentCard(
              'Active Deployments',
              'View and manage currently deployed components',
              Icons.play_circle_filled,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildDeploymentCard(
              'Pending Returns',
              'Components scheduled for return or overdue',
              Icons.schedule,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildDeploymentCard(
              'New Deployment',
              'Deploy components to laboratories',
              Icons.add_circle,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildDeploymentCard(
              'Deployment History',
              'View past deployments and analytics',
              Icons.history,
              Colors.purple,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new deployment form
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeploymentCard(
      String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
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
