import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddComponentPage extends StatefulWidget {
  final String? category;
  final String? componentId;

  const AddComponentPage({
    super.key,
    this.category,
    this.componentId,
  });

  @override
  State<AddComponentPage> createState() => _AddComponentPageState();
}

class _AddComponentPageState extends State<AddComponentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _assetTagController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _acquisitionCostController = TextEditingController();

  String _selectedCategory = 'CPU';
  String _selectedStatus = 'Available';
  DateTime _acquisitionDate = DateTime.now();
  DateTime? _warrantyExpiry;

  final List<String> _categories = [
    'CPU',
    'RAM',
    'Motherboard',
    'Graphics Card',
    'Storage',
    'Power Supply',
    'Case',
    'Monitor',
    'Keyboard',
    'Mouse',
    'Network',
    'Audio',
    'Other',
  ];

  final List<String> _statuses = [
    'Available',
    'Deployed',
    'Maintenance',
    'Damaged',
    'Disposed',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedCategory = widget.category!;
    }
    // If editing existing component, load data here
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _assetTagController.dispose();
    _descriptionController.dispose();
    _acquisitionCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.componentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Component' : 'Add Component',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Component Name *',
                  hintText: 'e.g., Dell OptiPlex 7090',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter component name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status *',
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand *',
                        hintText: 'e.g., Dell',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter brand';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model *',
                        hintText: 'e.g., OptiPlex 7090',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter model';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _serialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Serial Number *',
                        hintText: 'e.g., SN123456789',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter serial number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _assetTagController,
                      decoration: const InputDecoration(
                        labelText: 'Asset Tag *',
                        hintText: 'e.g., MIT2023001',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter asset tag';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Financial Information Section
              _buildSectionTitle('Financial Information'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Acquisition Date *',
                        ),
                        child: Text(
                          '${_acquisitionDate.day}/${_acquisitionDate.month}/${_acquisitionDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _acquisitionCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Acquisition Cost',
                        prefixText: '\$ ',
                        hintText: '0.00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Warranty Expiry (Optional)',
                  ),
                  child: Text(
                    _warrantyExpiry != null
                        ? '${_warrantyExpiry!.day}/${_warrantyExpiry!.month}/${_warrantyExpiry!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Additional Information Section
              _buildSectionTitle('Additional Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Additional details about the component...',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveComponent,
                  child: Text(
                    isEditing ? 'Update Component' : 'Add Component',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isAcquisitionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAcquisitionDate
          ? _acquisitionDate
          : (_warrantyExpiry ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isAcquisitionDate) {
          _acquisitionDate = picked;
        } else {
          _warrantyExpiry = picked;
        }
      });
    }
  }

  void _saveComponent() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.componentId != null
                ? 'Component updated successfully!'
                : 'Component added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Component',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to delete this component? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Component deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
