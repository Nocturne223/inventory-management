import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaboratoryPage extends StatelessWidget {
  const LaboratoryPage({super.key});

  @override
  Widget build(BuildContext context) {
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

            // Mock laboratory data
            _buildLaboratoryCard(
              'Computer Science Lab A',
              'Building A - Room 101',
              'Computer Science',
              25,
              22,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildLaboratoryCard(
              'Engineering Lab B',
              'Building B - Room 203',
              'Engineering',
              30,
              28,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildLaboratoryCard(
              'IT Support Center',
              'Building C - Room 105',
              'IT Support',
              15,
              8,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildLaboratoryCard(
              'Research Lab',
              'Building A - Room 301',
              'Research',
              20,
              12,
              Colors.purple,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add laboratory form
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLaboratoryCard(
    String name,
    String location,
    String department,
    int capacity,
    int occupied,
    Color color,
  ) {
    final occupancyRate = capacity > 0 ? occupied / capacity : 0.0;

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
                        name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: GoogleFonts.roboto(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Department: $department',
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
                  ],
                  onSelected: (value) {
                    // Handle menu actions
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
}
