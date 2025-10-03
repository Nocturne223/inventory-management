import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../utils/setup_admin.dart';

class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  bool _isLoading = false;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Check if Firebase is properly initialized
      if (Firebase.apps.isEmpty) {
        setState(() {
          _stats = {'error': 0};
        });
        return;
      }

      final db = FirebaseFirestore.instance;
      final collections = [
        'departments',
        'locations',
        'items',
        'system_units',
        'deployments'
      ];
      final stats = <String, int>{};

      for (final collection in collections) {
        try {
          final snapshot = await db.collection(collection).get();
          stats[collection] = snapshot.docs.length;
        } catch (e) {
          print('Error loading $collection: $e');
          stats[collection] = -1; // Indicate error
        }
      }

      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Firebase error: $e');
      setState(() {
        _stats = {'firebase_error': 0};
      });
    }
  }

  Future<void> _createAdminUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await AdminSetup.createDefaultAdmin();

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Admin user created!\nEmail: admin@mit.edu\nPassword: MITAdmin123!'),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating admin user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seedData() async {
    setState(() => _isLoading = true);

    try {
      // Check if Firebase is properly initialized
      if (Firebase.apps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Firebase not initialized')),
        );
        return;
      }

      final db = FirebaseFirestore.instance;

      // Add sample departments
      await db.collection('departments').doc('dept_001').set({
        'code': 'CBA',
        'name': 'College of Business & Accounting',
        'description': 'Business and accounting programs',
        'contact_person': 'Jane Smith',
        'contact_email': 'jane.smith@college.edu',
        'contact_phone': '02-555-1234',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await db.collection('departments').doc('dept_002').set({
        'code': 'CCS',
        'name': 'College of Computer Studies',
        'description': 'Computer science and IT programs',
        'contact_person': 'Alice Johnson',
        'contact_email': 'alice.johnson@college.edu',
        'contact_phone': '02-555-3456',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add sample items
      await db.collection('items').doc('item_001').set({
        'sku': 'ITM-RAM8',
        'name': '8GB DDR4 RAM',
        'description': '8GB DDR4 memory module',
        'categoryId': 'memory',
        'modelNumber': 'DDR4-8GB',
        'minimumStock': 5,
        'isSerialized': false,
        'status': 'active',
        'replacementCost': 75.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await db.collection('items').doc('item_002').set({
        'sku': 'ITM-SSD256',
        'name': '256GB SSD',
        'description': '256GB Solid State Drive',
        'categoryId': 'storage',
        'modelNumber': 'SSD-256GB',
        'minimumStock': 3,
        'isSerialized': true,
        'status': 'active',
        'replacementCost': 120.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add sample locations
      await db.collection('locations').doc('loc_001').set({
        'name': 'Main Building - Lab 101',
        'address': 'Main Building, Floor 1, Room 101',
        'contact_person': 'Tech Staff',
        'phone': '02-555-1111',
        'departmentId': 'dept_002',
        'roomIdentifier': '101',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Sample data added successfully!')),
      );

      await _loadStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content:
            const Text('This will permanently delete all data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Check if Firebase is properly initialized
      if (Firebase.apps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Firebase not initialized')),
        );
        return;
      }

      final db = FirebaseFirestore.instance;
      final collections = [
        'departments',
        'locations',
        'items',
        'system_units',
        'deployments'
      ];

      for (final collection in collections) {
        final snapshot = await db.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ All data cleared')),
      );

      await _loadStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_stats.isEmpty)
                      const Text('Loading...')
                    else
                      ..._stats.entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatCollectionName(entry.key)),
                                Text('${entry.value} records'),
                              ],
                            ),
                          )),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Operations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _seedData,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_circle),
                        label: const Text('Add Sample Data'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _clearData,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear All Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Authentication Setup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Setup',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a default admin user to access the system',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createAdminUser,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Create Admin User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Command Line Usage:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• dart tools/seed_data.dart seed'),
                  const Text('• dart tools/seed_data.dart stats'),
                  const Text('• dart tools/seed_data.dart clear'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCollectionName(String collection) {
    return collection
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
