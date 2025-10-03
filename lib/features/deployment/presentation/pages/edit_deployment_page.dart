import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/deployment_providers.dart';
import '../../../../core/models/deployment_models.dart';
import '../../../../providers/auth_provider.dart';

class EditDeploymentPage extends ConsumerStatefulWidget {
  final Deployment deployment;

  const EditDeploymentPage({
    super.key,
    required this.deployment,
  });

  @override
  ConsumerState<EditDeploymentPage> createState() => _EditDeploymentPageState();
}

class _EditDeploymentPageState extends ConsumerState<EditDeploymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _assignedToController = TextEditingController();
  final _assigneeEmailController = TextEditingController();
  final _notesController = TextEditingController();

  late Deployment _editableDeployment;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Create a copy of the deployment to edit
    _editableDeployment = widget.deployment.copyWith();

    // Pre-populate form fields
    _assignedToController.text = _editableDeployment.assignedTo;
    _assigneeEmailController.text = _editableDeployment.assigneeEmail;
    _notesController.text = _editableDeployment.notes ?? '';
  }

  @override
  void dispose() {
    _assignedToController.dispose();
    _assigneeEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentsProvider);
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Deployment',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateDeployment,
            child: Text(
              'Update',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
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
            if (_error != null) ...[
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
                        _error!,
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

            // Item Information (Read-only)
            _SectionHeader(title: 'Item Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editableDeployment.itemName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Item ID: ${_editableDeployment.itemId}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_editableDeployment.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _editableDeployment.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Assignee Information
            _SectionHeader(title: 'Assignee Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _assignedToController,
              decoration: InputDecoration(
                labelText: 'Assigned To *',
                hintText: 'Enter person or department name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Assigned to is required';
                }
                return null;
              },
              onChanged: (value) {
                _editableDeployment = _editableDeployment.copyWith(
                  assignedTo: value.trim(),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assigneeEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'Enter email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email address is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onChanged: (value) {
                _editableDeployment = _editableDeployment.copyWith(
                  assigneeEmail: value.trim(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Location & Department
            _SectionHeader(title: 'Location & Department'),
            const SizedBox(height: 12),
            departments.when(
              data: (deptList) {
                return DropdownButtonFormField<String>(
                  value: _editableDeployment.departmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: deptList.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _editableDeployment = _editableDeployment.copyWith(
                          departmentId: value,
                        );
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a department';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) =>
                  Text('Error loading departments: $error'),
            ),
            const SizedBox(height: 16),
            locations.when(
              data: (locationList) {
                return DropdownButtonFormField<String>(
                  value: _editableDeployment.locationId,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: locationList.map((location) {
                    return DropdownMenuItem<String>(
                      value: location.id,
                      child: Text(location.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _editableDeployment = _editableDeployment.copyWith(
                          locationId: value,
                        );
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) =>
                  Text('Error loading locations: $error'),
            ),
            const SizedBox(height: 24),

            // Expected Return Date
            _SectionHeader(title: 'Expected Return'),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectExpectedReturnDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _editableDeployment.expectedReturnDate != null
                          ? _formatDate(_editableDeployment.expectedReturnDate!)
                          : 'Select expected return date',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: _editableDeployment.expectedReturnDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Additional Notes
            _SectionHeader(title: 'Additional Notes'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional deployment notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              onChanged: (value) {
                _editableDeployment = _editableDeployment.copyWith(
                  notes: value.trim().isEmpty ? null : value.trim(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateDeployment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Update Deployment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpectedReturnDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _editableDeployment.expectedReturnDate ??
          DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _editableDeployment = _editableDeployment.copyWith(
          expectedReturnDate: selectedDate,
        );
      });
    }
  }

  Future<void> _updateDeployment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _error = 'User not authenticated';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(deploymentServiceProvider);

      // Prepare update data
      final updates = {
        'assignedTo': _editableDeployment.assignedTo,
        'assigneeEmail': _editableDeployment.assigneeEmail,
        'departmentId': _editableDeployment.departmentId,
        'locationId': _editableDeployment.locationId,
        'expectedReturnDate': _editableDeployment.expectedReturnDate,
        'notes': _editableDeployment.notes,
        'updatedBy': user.email,
      };

      await service.updateDeployment(_editableDeployment.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deployment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update deployment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'pending-return':
        return Colors.orange;
      case 'returned':
        return Colors.blue;
      default:
        return Colors.grey;
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
