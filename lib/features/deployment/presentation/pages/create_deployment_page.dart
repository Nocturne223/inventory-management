import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/deployment_providers.dart';
import '../../../../core/models/deployment_models.dart';
import '../../../../providers/auth_provider.dart';

class CreateDeploymentPage extends ConsumerStatefulWidget {
  const CreateDeploymentPage({super.key});

  @override
  ConsumerState<CreateDeploymentPage> createState() =>
      _CreateDeploymentPageState();
}

class _CreateDeploymentPageState extends ConsumerState<CreateDeploymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _assignedToController = TextEditingController();
  final _assigneeEmailController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _assignedToController.dispose();
    _assigneeEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(deploymentFormProvider);
    final availableItems = ref.watch(availableItemsProvider);
    final departments = ref.watch(departmentsProvider);
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Deployment',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _createDeployment,
            child: Text(
              'Deploy',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: formState.isLoading
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (formState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.error!,
                        style: GoogleFonts.inter(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Item Selection
            _SectionHeader(title: 'Select Item'),
            const SizedBox(height: 12),
            availableItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No available items to deploy. All items are currently in use, maintenance, or retired.',
                            style: GoogleFonts.inter(
                              color: Colors.orange[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: formState.selectedItemId,
                  decoration: const InputDecoration(
                    labelText: 'Item to Deploy *',
                    border: OutlineInputBorder(),
                    hintText: 'Select an item to deploy',
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${item.brand} ${item.model} • S/N: ${item.serialNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref
                        .read(deploymentFormProvider.notifier)
                        .updateSelectedItem(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an item to deploy';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading items'),
            ),
            const SizedBox(height: 24),

            // Assignee Information
            _SectionHeader(title: 'Assignee Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _assignedToController,
              decoration: const InputDecoration(
                labelText: 'Assigned To *',
                border: OutlineInputBorder(),
                hintText: 'Full name of person receiving the item',
              ),
              onChanged: (value) {
                ref
                    .read(deploymentFormProvider.notifier)
                    .updateAssignedTo(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the assignee name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assigneeEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                hintText: 'email@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                ref
                    .read(deploymentFormProvider.notifier)
                    .updateAssigneeEmail(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Location & Department
            _SectionHeader(title: 'Location & Department'),
            const SizedBox(height: 12),
            departments.when(
              data: (depts) {
                return DropdownButtonFormField<String>(
                  value: formState.selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                  ),
                  items: depts.map((dept) {
                    return DropdownMenuItem(
                      value: dept.id,
                      child: Text('${dept.code} - ${dept.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref
                        .read(deploymentFormProvider.notifier)
                        .updateDepartment(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a department';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading departments'),
            ),
            const SizedBox(height: 16),
            locations.when(
              data: (locs) {
                return DropdownButtonFormField<String>(
                  value: formState.selectedLocationId,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(),
                  ),
                  items: locs.map((loc) {
                    return DropdownMenuItem(
                      value: loc.id,
                      child:
                          Text('${loc.name} (${loc.building} - ${loc.room})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref
                        .read(deploymentFormProvider.notifier)
                        .updateLocation(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading locations'),
            ),
            const SizedBox(height: 24),

            // Expected Return Date
            _SectionHeader(title: 'Expected Return'),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectReturnDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expected Return Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  formState.expectedReturnDate != null
                      ? _formatDate(formState.expectedReturnDate!)
                      : 'Select return date (optional)',
                  style: GoogleFonts.inter(
                    color: formState.expectedReturnDate != null
                        ? null
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            _SectionHeader(title: 'Additional Notes'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'Any additional information or special instructions',
              ),
              maxLines: 3,
              onChanged: (value) {
                ref.read(deploymentFormProvider.notifier).updateNotes(value);
              },
            ),
            const SizedBox(height: 32),

            // Deploy Button
            ElevatedButton(
              onPressed: formState.isLoading ? null : _createDeployment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: formState.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Create Deployment',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      ref
          .read(deploymentFormProvider.notifier)
          .updateExpectedReturnDate(selectedDate);
    }
  }

  Future<void> _createDeployment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = ref.read(deploymentFormProvider);
    if (!formState.isValid) {
      ref
          .read(deploymentFormProvider.notifier)
          .setError('Please fill in all required fields');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ref
          .read(deploymentFormProvider.notifier)
          .setError('User not authenticated');
      return;
    }

    // Get item name for the deployment
    final availableItems = await ref.read(availableItemsProvider.future);
    final selectedItem = availableItems
        .firstWhere((item) => item.id == formState.selectedItemId);

    ref.read(deploymentFormProvider.notifier).setLoading(true);
    ref.read(deploymentFormProvider.notifier).setError(null);

    try {
      final service = ref.read(deploymentServiceProvider);

      final deployment = Deployment(
        id: '', // Will be set by Firestore
        itemId: formState.selectedItemId!,
        itemName: selectedItem.name,
        assignedTo: formState.assignedTo,
        assigneeEmail: formState.assigneeEmail,
        departmentId: formState.selectedDepartmentId!,
        locationId: formState.selectedLocationId!,
        status: 'active',
        deployedAt: DateTime.now(),
        expectedReturnDate: formState.expectedReturnDate,
        notes: formState.notes.isNotEmpty ? formState.notes : null,
        deployedBy: user.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.createDeployment(deployment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deployment created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form and navigate back
        ref.read(deploymentFormProvider.notifier).reset();
        Navigator.pop(context);
      }
    } catch (e) {
      ref
          .read(deploymentFormProvider.notifier)
          .setError('Failed to create deployment: $e');
    } finally {
      ref.read(deploymentFormProvider.notifier).setLoading(false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
