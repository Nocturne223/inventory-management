import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/services/firestore_data_service.dart';

// (Use the centralized providers from the Firestore data service)

class RecentActivitiesWidget extends ConsumerWidget {
  const RecentActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the enriched deployments stream so department/location/user names
    // are already resolved by the service layer.
    final deploymentsAsync = ref.watch(recentEnrichedDeploymentsProvider);

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
                  Navigator.pushNamed(context, '/deployments');
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
          deploymentsAsync.when(
            data: (deployments) {
              if (deployments.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent activities',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Convert deployments to activities and sort by date
              final activities = deployments
                  .map((deployment) => ActivityItem(
                        type: _getActivityType(deployment['status'] as String),
                        title: _getActivityTitle(deployment),
                        subtitle: _getActivitySubtitle(deployment),
                        timestamp: _parseDateTime(deployment['deployedAt']) ??
                            _parseDateTime(deployment['createdAt']) ??
                            DateTime.now(),
                        icon: _getActivityIcon(deployment['status'] as String),
                        color:
                            _getActivityColor(deployment['status'] as String),
                      ))
                  .toList();

              activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return Column(
                children: activities
                    .take(5)
                    .map((activity) => _ActivityListItem(
                          activity: activity,
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading activities',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date string: $dateValue, error: $e');
        return null;
      }
    }

    return null;
  }

  ActivityType _getActivityType(String status) {
    switch (status.toLowerCase()) {
      case 'deployed':
        return ActivityType.deployment;
      case 'returned':
        return ActivityType.returned;
      case 'maintenance':
        return ActivityType.maintenance;
      default:
        return ActivityType.deployment;
    }
  }

  String _getActivityTitle(Map<String, dynamic> deployment) {
    final itemName = deployment['itemName'] as String? ?? 'Item';
    final status = deployment['status'] as String? ?? 'deployed';

    switch (status.toLowerCase()) {
      case 'deployed':
        return '$itemName deployed';
      case 'returned':
        return '$itemName returned';
      case 'maintenance':
        return '$itemName under maintenance';
      default:
        return '$itemName activity';
    }
  }

  String _getActivitySubtitle(Map<String, dynamic> deployment) {
    final department =
        deployment['department'] as String? ?? 'Unknown Department';
    final location = deployment['location'] as String? ?? 'Unknown Location';
    final requestedBy = deployment['requestedBy'] as String? ?? 'Unknown User';

    return '$department - $location (by $requestedBy)';
  }

  IconData _getActivityIcon(String status) {
    switch (status.toLowerCase()) {
      case 'deployed':
        return Icons.send;
      case 'returned':
        return Icons.keyboard_return;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String status) {
    switch (status.toLowerCase()) {
      case 'deployed':
        return Colors.blue;
      case 'returned':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
