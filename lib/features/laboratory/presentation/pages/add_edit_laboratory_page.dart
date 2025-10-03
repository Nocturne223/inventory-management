import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/inventory_models.dart';
import '../../../../services/firestore_data_service.dart';

class AddEditLaboratoryPage extends ConsumerStatefulWidget {
  final Location? laboratory;
  final bool isEditing;

  const AddEditLaboratoryPage({
    super.key,
    this.laboratory,
    this.isEditing = false,
  });

  @override
  ConsumerState<AddEditLaboratoryPage> createState() =>
      _AddEditLaboratoryPageState();
}

class _AddEditLaboratoryPageState extends ConsumerState<AddEditLaboratoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.laboratory != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final lab = widget.laboratory!;
    _nameController.text = lab.name;
    _buildingController.text = lab.building;
    _roomController.text = lab.room;
    _capacityController.text = lab.capacity.toString();
    _descriptionController.text = lab.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveLaboratory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreDataServiceProvider);

      if (widget.isEditing && widget.laboratory != null) {
        // Update existing location
        final locationData = {
          'name': _nameController.text.trim(),
          'building': _buildingController.text.trim(),
          'room': _roomController.text.trim(),
          'capacity': int.parse(_capacityController.text.trim()),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        };
        await service.updateLocation(widget.laboratory!.id, locationData);
      } else {
        // Add new location
        final newLocation = Location(
          id: '', // This will be set by Firestore
          name: _nameController.text.trim(),
          building: _buildingController.text.trim(),
          room: _roomController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );
        await service.addLocation(newLocation);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Laboratory updated successfully'
                  : 'Laboratory added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving laboratory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Laboratory' : 'Add Laboratory',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveLaboratory,
            child: Text(
              'Save',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditing
                          ? 'Update laboratory information'
                          : 'Enter laboratory details',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Laboratory Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Laboratory Name *',
                        hintText: 'e.g., Computer Science Lab A',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.science),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a laboratory name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Building
                    TextFormField(
                      controller: _buildingController,
                      decoration: InputDecoration(
                        labelText: 'Building *',
                        hintText: 'e.g., Building A',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a building name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Room
                    TextFormField(
                      controller: _roomController,
                      decoration: InputDecoration(
                        labelText: 'Room Number *',
                        hintText: 'e.g., Room 101',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.door_front_door),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a room number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Capacity
                    TextFormField(
                      controller: _capacityController,
                      decoration: InputDecoration(
                        labelText: 'Capacity *',
                        hintText: 'e.g., 30',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.people),
                        suffixText: 'stations',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the laboratory capacity';
                        }
                        final capacity = int.tryParse(value.trim());
                        if (capacity == null || capacity <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Brief description of the laboratory...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveLaboratory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Update Laboratory'
                                    : 'Add Laboratory',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
}
