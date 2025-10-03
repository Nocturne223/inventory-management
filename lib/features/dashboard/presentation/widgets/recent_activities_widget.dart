import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecentActivitiesWidget extends StatelessWidget {
  const RecentActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for recent activities
    final activities = [
      ActivityItem(
        type: ActivityType.deployment,
        title: 'Dell OptiPlex 7090 deployed',
        subtitle: 'Computer Science Lab A',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        icon: Icons.computer,
        color: Colors.blue,
      ),
      ActivityItem(
        type: ActivityType.maintenance,
        title: 'HP LaserJet Pro maintenance completed',
        subtitle: 'Engineering Lab B',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.build,
        color: Colors.orange,
      ),
      ActivityItem(
        type: ActivityType.addition,
        title: 'New components added',
        subtitle: '15 RAM modules, 8 SSDs',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.add_circle,
        color: Colors.green,
      ),
      ActivityItem(
        type: ActivityType.returned,
        title: 'MacBook Pro returned',
        subtitle: 'From IT Support Team',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.keyboard_return,
        color: Colors.purple,
      ),
      ActivityItem(
        type: ActivityType.alert,
        title: 'Low stock alert',
        subtitle: 'DDR4 RAM modules below threshold',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.warning,
        color: Colors.red,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity log
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.take(5).map((activity) => _ActivityListItem(
                activity: activity,
              )),
        ],
      ),
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityListItem({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity.subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(activity.timestamp),
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

enum ActivityType {
  deployment,
  maintenance,
  addition,
  returned,
  alert,
}
