import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/deployment_providers.dart';
import '../../../../core/models/deployment_models.dart';
import '../../../../providers/auth_provider.dart';
import 'edit_deployment_page.dart';

class DeploymentDetailPage extends ConsumerWidget {
  final String deploymentId;

  const DeploymentDetailPage({
    super.key,
    required this.deploymentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deploymentAsync = ref.watch(deploymentProvider(deploymentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deployment Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'extend',
                child: ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text('Extend Deployment'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'return',
                child: ListTile(
                  leading: Icon(Icons.assignment_return),
                  title: Text('Return Item'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Details'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: deploymentAsync.when(
        data: (deployment) {
          if (deployment == null) {
            return const Center(
              child: Text('Deployment not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Item Header
                _HeaderCard(deployment: deployment),
                const SizedBox(height: 16),

                // Assignee Information
                _InfoSection(
                  title: 'Assignee Information',
                  children: [
                    _InfoRow('Assigned To', deployment.assignedTo),
                    _InfoRow('Email', deployment.assigneeEmail),
                  ],
                ),
                const SizedBox(height: 16),

                // Deployment Details
                _InfoSection(
                  title: 'Deployment Details',
                  children: [
                    _InfoRow('Deployed On', _formatDate(deployment.deployedAt)),
                    _InfoRow('Deployed By', deployment.deployedBy),
                    if (deployment.expectedReturnDate != null)
                      _InfoRow(
                        'Expected Return',
                        _formatDate(deployment.expectedReturnDate!),
                        isHighlight: deployment.isOverdue,
                      ),
                    if (deployment.actualReturnDate != null)
                      _InfoRow('Actual Return',
                          _formatDate(deployment.actualReturnDate!)),
                    _InfoRow('Duration', _getDurationText(deployment)),
                    if (deployment.notes != null)
                      _InfoRow('Notes', deployment.notes!),
                  ],
                ),

                // Return Information (if returned)
                if (deployment.status == 'returned') ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: 'Return Information',
                    children: [
                      if (deployment.returnCondition != null)
                        _InfoRow('Condition', deployment.returnCondition!),
                      if (deployment.returnNotes != null)
                        _InfoRow('Return Notes', deployment.returnNotes!),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                if (deployment.status == 'active')
                  _ActionButtons(deployment: deployment),
              ],
            ),
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
                'Error loading deployment',
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
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    final deployment = await ref.read(deploymentProvider(deploymentId).future);
    if (deployment == null) return;

    switch (action) {
      case 'extend':
        _showExtendDialog(context, ref, deployment);
        break;
      case 'return':
        _showReturnDialog(context, ref, deployment);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditDeploymentPage(deployment: deployment),
          ),
        );
        break;
    }
  }

  void _showExtendDialog(
      BuildContext context, WidgetRef ref, Deployment deployment) {
    DateTime? newReturnDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Deployment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current expected return: ${deployment.expectedReturnDate != null ? _formatDate(deployment.expectedReturnDate!) : "Not set"}',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: deployment.expectedReturnDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null) {
                  newReturnDate = selectedDate;
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'New Return Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  newReturnDate != null
                      ? _formatDate(newReturnDate!)
                      : 'Select new date',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Extension',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newReturnDate != null) {
                try {
                  final user = ref.read(currentUserProvider);
                  final service = ref.read(deploymentServiceProvider);

                  await service.extendDeployment(
                    deploymentId,
                    newReturnDate!,
                    user?.email ?? 'Unknown User',
                    reasonController.text.isNotEmpty
                        ? reasonController.text
                        : null,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deployment extended successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to extend deployment: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(
      BuildContext context, WidgetRef ref, Deployment deployment) {
    final returnForm = ref.read(returnFormProvider.notifier);
    returnForm.reset();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final formState = ref.watch(returnFormProvider);

          return AlertDialog(
            title: const Text('Return Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Item: ${deployment.itemName}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: formState.returnCondition,
                  decoration: const InputDecoration(
                    labelText: 'Return Condition',
                    border: OutlineInputBorder(),
                  ),
                  items: returnConditionOptions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(_getConditionDisplayName(condition)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    returnForm.updateReturnCondition(value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Return Notes',
                    border: OutlineInputBorder(),
                    hintText: 'Any comments about the return...',
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    returnForm.updateReturnNotes(value);
                  },
                ),
                if (formState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    formState.error!,
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    formState.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: formState.isLoading
                    ? null
                    : () async {
                        try {
                          returnForm.setLoading(true);
                          final user = ref.read(currentUserProvider);
                          final service = ref.read(deploymentServiceProvider);

                          await service.returnItem(
                            deploymentId,
                            formState.returnCondition,
                            formState.returnNotes.isNotEmpty
                                ? formState.returnNotes
                                : null,
                            user?.email ?? 'Unknown User',
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item returned successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          returnForm.setError('Failed to return item: $e');
                        } finally {
                          returnForm.setLoading(false);
                        }
                      },
                child: formState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Return Item'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDurationText(Deployment deployment) {
    final days = deployment.deploymentDuration;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  String _getConditionDisplayName(String condition) {
    switch (condition) {
      case 'good':
        return 'Good Condition';
      case 'damaged':
        return 'Damaged';
      case 'needs-maintenance':
        return 'Needs Maintenance';
      default:
        return condition;
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final Deployment deployment;

  const _HeaderCard({required this.deployment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    deployment.itemName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(deployment: deployment),
              ],
            ),
            const SizedBox(height: 8),
            if (deployment.isOverdue) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'This deployment is overdue!',
                      style: GoogleFonts.inter(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
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

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow(
    this.label,
    this.value, {
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                color: isHighlight ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Deployment deployment;

  const _ActionButtons({required this.deployment});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Handle extend deployment
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Extend'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle return item
            },
            icon: const Icon(Icons.assignment_return),
            label: const Text('Return'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
