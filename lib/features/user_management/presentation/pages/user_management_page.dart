import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/user_management_provider.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _searchQuery = '';
  UserRole? _filterRole;
  bool _filterActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userManagementState = ref.watch(userManagementProvider);

    // Filter parameters for the provider
    final filterParams = {
      'searchQuery': _searchQuery,
      'filterRole': _filterRole,
      'filterActiveOnly': _filterActiveOnly,
    };
    final filteredUsers = ref.watch(filteredUsersProvider(filterParams));

    // Check if user has permission to access user management
    if (currentUser?.role != UserRole.superAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Access Denied',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You need SuperAdmin privileges to access User Management.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUserDialog(),
            tooltip: 'Add New User',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<UserRole?>(
                        value: _filterRole,
                        decoration: InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<UserRole?>(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          ...UserRole.values
                              .map((role) => DropdownMenuItem<UserRole?>(
                                    value: role,
                                    child: Text(role.displayName),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterRole = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text('Active Only'),
                      selected: _filterActiveOnly,
                      onSelected: (selected) {
                        setState(() {
                          _filterActiveOnly = selected;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(filteredUsers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.firstName[0] + user.lastName[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.displayName,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.department,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
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
                    title: Text('Edit User'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: ListTile(
                    leading: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    title: Text(user.isActive ? 'Deactivate' : 'Activate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (user.role != UserRole.superAdmin)
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete User',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.technician:
        return Colors.blue;
      case UserRole.user:
        return Colors.green;
    }
  }

  void _handleUserAction(String action, AppUser user) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showUserDetailsDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role.displayName),
              _buildDetailRow('Department', user.department),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Created', _formatDate(user.createdAt)),
              _buildDetailRow('Last Login', _formatDate(user.lastLoginAt)),
              const SizedBox(height: 16),
              Text(
                'Permissions:',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...user.role.defaultPermissions.map(
                (permission) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $permission'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final departmentController = TextEditingController();
    UserRole selectedRole = UserRole.user;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person_add, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Add New User',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: 'Enter user email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        // Check if email already exists
                        final existingUsers =
                            ref.read(userManagementProvider).users;
                        if (existingUsers.any((user) =>
                            user.email.toLowerCase() == value.toLowerCase())) {
                          return 'This email is already registered';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // First Name Field
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: 'Enter first name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Enter last name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        hintText: 'Enter phone number (optional)',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Department Field
                    TextFormField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                        hintText: 'Enter department name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Department is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Selection
                    DropdownButtonFormField<UserRole>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'User Role *',
                        prefixIcon: Icon(Icons.admin_panel_settings),
                        border: OutlineInputBorder(),
                      ),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getRoleColor(role),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(role.displayName),
                              const SizedBox(width: 8),
                              Text(
                                '(Level ${role.level})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (UserRole? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a user role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Active Status Switch
                    Row(
                      children: [
                        const Icon(Icons.toggle_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Account Status:',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() {
                              isActive = value;
                            });
                          },
                        ),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Permissions Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Role Permissions:',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: selectedRole.defaultPermissions
                                .map((permission) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(selectedRole)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getRoleColor(selectedRole)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  permission,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getRoleColor(selectedRole),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Create new user
                  final newUser = AppUser(
                    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                    email: emailController.text.trim(),
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    displayName:
                        '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
                    role: selectedRole,
                    department: departmentController.text.trim(),
                    phoneNumber: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    profileImageUrl: null,
                    isActive: isActive,
                    createdAt: DateTime.now(),
                    lastLoginAt:
                        DateTime.now(), // Set to creation time for new users
                    permissions: {
                      'roles': selectedRole.defaultPermissions,
                      'customPermissions': <String>[],
                    },
                  );

                  // Add to users list using provider
                  try {
                    await ref
                        .read(userManagementProvider.notifier)
                        .addUser(newUser);

                    Navigator.pop(context);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'User ${newUser.displayName} created successfully',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Failed to create user: $e'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(AppUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit User: ${user.displayName} - Coming Soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleUserStatus(AppUser user) async {
    try {
      await ref.read(userManagementProvider.notifier).toggleUserStatus(user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.displayName} ${user.isActive ? 'deactivated' : 'activated'} successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(userManagementProvider.notifier)
                    .deleteUser(user.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.displayName} deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete user: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
