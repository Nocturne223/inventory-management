import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/deployment_providers.dart';
import '../../../../core/models/deployment_models.dart';
import 'create_deployment_page.dart';
import 'deployment_detail_page.dart';

class DeploymentListPage extends ConsumerStatefulWidget {
  const DeploymentListPage({super.key});

  @override
  ConsumerState<DeploymentListPage> createState() => _DeploymentListPageState();
}

class _DeploymentListPageState extends ConsumerState<DeploymentListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deploymentsAsync = ref.watch(filteredDeploymentsProvider);
    final deploymentStats = ref.watch(deploymentStatsProvider);
    final searchQuery = ref.watch(deploymentSearchQueryProvider);
    final statusFilter = ref.watch(deploymentStatusFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header and Statistics
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Create Button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Deployment Management',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateDeploymentPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Deployment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statistics Cards
                deploymentStats.when(
                  data: (stats) => _StatisticsRow(stats: stats),
                  loading: () => const _StatisticsLoadingRow(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Search and Filters
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search deployments...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          ref
                              .read(deploymentSearchQueryProvider.notifier)
                              .state = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: deploymentStatusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusDisplayName(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          ref
                              .read(deploymentStatusFilterProvider.notifier)
                              .state = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Deployments List
          Expanded(
            child: deploymentsAsync.when(
              data: (deployments) {
                if (deployments.isEmpty) {
                  return _EmptyState(
                    hasFilter: searchQuery.isNotEmpty || statusFilter != 'All',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: deployments.length,
                  itemBuilder: (context, index) {
                    final deployment = deployments[index];
                    return _DeploymentCard(
                      deployment: deployment,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeploymentDetailPage(
                              deploymentId: deployment.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading deployments',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'All':
        return 'All Status';
      case 'active':
        return 'Active';
      case 'returned':
        return 'Returned';
      case 'overdue':
        return 'Overdue';
      default:
        return status;
    }
  }
}

class _StatisticsRow extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatisticsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: stats['total']?.toString() ?? '0',
            icon: Icons.inventory_2,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Active',
            value: stats['active']?.toString() ?? '0',
            icon: Icons.play_circle_filled,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Overdue',
            value: stats['overdue']?.toString() ?? '0',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Completed',
            value: stats['completed']?.toString() ?? '0',
            icon: Icons.check_circle,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _StatisticsLoadingRow extends StatelessWidget {
  const _StatisticsLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeploymentCard extends StatelessWidget {
  final Deployment deployment;
  final VoidCallback onTap;

  const _DeploymentCard({
    required this.deployment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deployment.itemName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(deployment: deployment),
                  const SizedBox(width: 8),
                  // Action Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.pushNamed(
                            context,
                            '/deployments/edit',
                            arguments: deployment,
                          );
                          break;
                        case 'return':
                          _showReturnDialog(context, deployment);
                          break;
                        case 'delete':
                          _showDeleteDialog(context, deployment);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (deployment.status == 'active')
                        const PopupMenuItem(
                          value: 'return',
                          child: Row(
                            children: [
                              Icon(Icons.keyboard_return, size: 16),
                              SizedBox(width: 8),
                              Text('Return Item'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Assignee Info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deployment.assignedTo,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Email
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deployment.assigneeEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dates and Duration
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Deployed',
                      value: _formatDate(deployment.deployedAt),
                    ),
                  ),
                  if (deployment.expectedReturnDate != null)
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.event,
                        label: deployment.isOverdue ? 'Overdue by' : 'Due in',
                        value: _getDueDateText(deployment),
                        isOverdue: deployment.isOverdue,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDueDateText(Deployment deployment) {
    if (deployment.expectedReturnDate == null) return '';

    final days = deployment.daysUntilReturn.abs();
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  void _showReturnDialog(BuildContext context, Deployment deployment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Are you sure you want to mark "${deployment.itemName}" as returned?'),
            const SizedBox(height: 16),
            const Text(
                'Note: This action will update the item status and close the deployment.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement return functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Return functionality not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Deployment deployment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deployment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Are you sure you want to delete the deployment of "${deployment.itemName}"?'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality not implemented yet'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Deployment deployment;

  const _StatusChip({required this.deployment});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    if (deployment.isOverdue) {
      backgroundColor = Colors.red[100]!;
      textColor = Colors.red[800]!;
      displayText = 'OVERDUE';
    } else {
      switch (deployment.status.toLowerCase()) {
        case 'active':
          backgroundColor = Colors.green[100]!;
          textColor = Colors.green[800]!;
          displayText = 'ACTIVE';
          break;
        case 'returned':
          backgroundColor = Colors.grey[100]!;
          textColor = Colors.grey[800]!;
          displayText = 'RETURNED';
          break;
        default:
          backgroundColor = Colors.blue[100]!;
          textColor = Colors.blue[800]!;
          displayText = deployment.status.toUpperCase();
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isOverdue;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isOverdue ? Colors.red : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isOverdue ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter ? Icons.search_off : Icons.send_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No deployments found' : 'No deployments yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Try adjusting your search or filters'
                : 'Create your first deployment to get started',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDeploymentPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Deployment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
