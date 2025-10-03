import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/user.dart';

// User Management State
class UserManagementState {
  final List<AppUser> users;
  final bool isLoading;
  final String? error;

  UserManagementState({
    required this.users,
    this.isLoading = false,
    this.error,
  });

  UserManagementState copyWith({
    List<AppUser>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User Management Notifier
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(UserManagementState(users: _initialUsers));

  // Initial mock users data
  static final List<AppUser> _initialUsers = [
    AppUser(
      id: 'user_001',
      email: 'superadmin@mit.edu',
      firstName: 'Emma',
      lastName: 'SuperAdmin',
      displayName: 'Emma SuperAdmin',
      role: UserRole.superAdmin,
      department: 'IT Department',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      permissions: {
        'roles': UserRole.superAdmin.defaultPermissions,
        'customPermissions': <String>[],
      },
    ),
    AppUser(
      id: 'user_002',
      email: 'admin@mit.edu',
      firstName: 'John',
      lastName: 'Administrator',
      displayName: 'John Administrator',
      role: UserRole.admin,
      department: 'IT Department',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
      permissions: {
        'roles': UserRole.admin.defaultPermissions,
        'customPermissions': <String>[],
      },
    ),
    AppUser(
      id: 'user_003',
      email: 'manager@mit.edu',
      firstName: 'Sarah',
      lastName: 'Manager',
      displayName: 'Sarah Manager',
      role: UserRole.manager,
      department: 'Engineering',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      permissions: {
        'roles': UserRole.manager.defaultPermissions,
        'customPermissions': <String>[],
      },
    ),
    AppUser(
      id: 'user_004',
      email: 'technician@mit.edu',
      firstName: 'Mike',
      lastName: 'Technician',
      displayName: 'Mike Technician',
      role: UserRole.technician,
      department: 'Maintenance',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
      permissions: {
        'roles': UserRole.technician.defaultPermissions,
        'customPermissions': <String>[],
      },
    ),
    AppUser(
      id: 'user_005',
      email: 'user@mit.edu',
      firstName: 'Jane',
      lastName: 'User',
      displayName: 'Jane User',
      role: UserRole.user,
      department: 'Research',
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 7)),
      permissions: {
        'roles': UserRole.user.defaultPermissions,
        'customPermissions': <String>[],
      },
    ),
  ];

  // Add a new user
  Future<void> addUser(AppUser user) async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Check for duplicate email
      if (state.users
          .any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
        throw Exception('A user with this email already exists');
      }

      final updatedUsers = [...state.users, user];
      updatedUsers.sort((a, b) => a.displayName.compareTo(b.displayName));

      state = state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update a user
  Future<void> updateUser(AppUser user) async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUsers = state.users.map((u) {
        return u.id == user.id ? user : u;
      }).toList();

      state = state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUsers = state.users.where((u) => u.id != userId).toList();

      state = state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Toggle user status
  Future<void> toggleUserStatus(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final updatedUsers = state.users.map((u) {
        if (u.id == userId) {
          return AppUser(
            id: u.id,
            email: u.email,
            firstName: u.firstName,
            lastName: u.lastName,
            displayName: u.displayName,
            role: u.role,
            department: u.department,
            phoneNumber: u.phoneNumber,
            profileImageUrl: u.profileImageUrl,
            isActive: !u.isActive,
            createdAt: u.createdAt,
            lastLoginAt: u.lastLoginAt,
            permissions: u.permissions,
          );
        }
        return u;
      }).toList();

      state = state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get user by ID
  AppUser? getUserById(String userId) {
    try {
      return state.users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get users by role
  List<AppUser> getUsersByRole(UserRole role) {
    return state.users.where((user) => user.role == role).toList();
  }

  // Get active users
  List<AppUser> getActiveUsers() {
    return state.users.where((user) => user.isActive).toList();
  }
}

// Providers
final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier();
});

// Filtered users provider (for search and filtering)
final filteredUsersProvider =
    Provider.family<List<AppUser>, Map<String, dynamic>>((ref, filters) {
  final userState = ref.watch(userManagementProvider);
  final users = userState.users;

  final searchQuery = filters['searchQuery'] as String? ?? '';
  final filterRole = filters['filterRole'] as UserRole?;
  final filterActiveOnly = filters['filterActiveOnly'] as bool? ?? false;

  return users.where((user) {
    // Search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      if (!user.displayName.toLowerCase().contains(query) &&
          !user.email.toLowerCase().contains(query) &&
          !user.department.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Role filter
    if (filterRole != null && user.role != filterRole) {
      return false;
    }

    // Active filter
    if (filterActiveOnly && !user.isActive) {
      return false;
    }

    return true;
  }).toList();
});
