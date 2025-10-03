// import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final UserRole role;
  final String department;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> permissions;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.role,
    required this.department,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    required this.permissions,
  });

  // Temporarily disabled for testing without Firebase
  // factory AppUser.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return AppUser(
  //     id: doc.id,
  //     email: data['email'] ?? '',
  //     firstName: data['firstName'] ?? '',
  //     lastName: data['lastName'] ?? '',
  //     displayName: data['displayName'] ?? '',
  //     role: UserRole.values.firstWhere(
  //       (r) => r.name == data['role'],
  //       orElse: () => UserRole.user,
  //     ),
  //     department: data['department'] ?? '',
  //     phoneNumber: data['phoneNumber'],
  //     profileImageUrl: data['profileImageUrl'],
  //     isActive: data['isActive'] ?? true,
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
  //     permissions: Map<String, dynamic>.from(data['permissions'] ?? {}),
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'email': email,
  //     'firstName': firstName,
  //     'lastName': lastName,
  //     'displayName': displayName,
  //     'role': role.name,
  //     'department': department,
  //     'phoneNumber': phoneNumber,
  //     'profileImageUrl': profileImageUrl,
  //     'isActive': isActive,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'lastLoginAt': Timestamp.fromDate(lastLoginAt),
  //     'permissions': permissions,
  //   };
  // }

  String get fullName => '$firstName $lastName';

  bool hasPermission(String permission) {
    return permissions[permission] == true || role.hasPermission(permission);
  }

  AppUser copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    UserRole? role,
    String? department,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    DateTime? lastLoginAt,
    Map<String, dynamic>? permissions,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }
}

enum UserRole {
  superAdmin,
  admin,
  manager,
  technician,
  user,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.technician:
        return 'Technician';
      case UserRole.user:
        return 'User';
    }
  }

  List<String> get defaultPermissions {
    switch (this) {
      case UserRole.superAdmin:
        return [
          'create_component',
          'edit_component',
          'delete_component',
          'view_analytics',
          'manage_users',
          'manage_system',
          'manage_data',
          'manage_laboratories',
          'create_deployment',
          'manage_maintenance',
          'generate_reports',
          'system_configuration',
          'backup_restore',
        ];
      case UserRole.admin:
        return [
          'create_component',
          'edit_component',
          'delete_component',
          'view_analytics',
          'manage_users',
          'manage_laboratories',
          'create_deployment',
          'manage_maintenance',
          'generate_reports',
        ];
      case UserRole.manager:
        return [
          'create_component',
          'edit_component',
          'view_analytics',
          'manage_laboratories',
          'create_deployment',
          'manage_maintenance',
          'generate_reports',
        ];
      case UserRole.technician:
        return [
          'create_component',
          'edit_component',
          'create_deployment',
          'manage_maintenance',
        ];
      case UserRole.user:
        return [
          'view_components',
          'create_deployment',
        ];
    }
  }

  bool hasPermission(String permission) {
    return defaultPermissions.contains(permission);
  }

  int get level {
    switch (this) {
      case UserRole.superAdmin:
        return 5;
      case UserRole.admin:
        return 4;
      case UserRole.manager:
        return 3;
      case UserRole.technician:
        return 2;
      case UserRole.user:
        return 1;
    }
  }
}

class MaintenanceRecord {
  final String id;
  final String componentId;
  final MaintenanceType type;
  final String description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final MaintenanceStatus status;
  final String technician;
  final double? cost;
  final String? notes;
  final List<String> partsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord({
    required this.id,
    required this.componentId,
    required this.type,
    required this.description,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    required this.technician,
    this.cost,
    this.notes,
    required this.partsUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  // Temporarily disabled for testing without Firebase
  // factory MaintenanceRecord.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return MaintenanceRecord(
  //     id: doc.id,
  //     componentId: data['componentId'] ?? '',
  //     type: MaintenanceType.values.firstWhere(
  //       (t) => t.name == data['type'],
  //       orElse: () => MaintenanceType.repair,
  //     ),
  //     description: data['description'] ?? '',
  //     scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
  //     completedDate: data['completedDate'] != null
  //         ? (data['completedDate'] as Timestamp).toDate()
  //         : null,
  //     status: MaintenanceStatus.values.firstWhere(
  //       (s) => s.name == data['status'],
  //       orElse: () => MaintenanceStatus.scheduled,
  //     ),
  //     technician: data['technician'] ?? '',
  //     cost: data['cost']?.toDouble(),
  //     notes: data['notes'],
  //     partsUsed: List<String>.from(data['partsUsed'] ?? []),
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'componentId': componentId,
  //     'type': type.name,
  //     'description': description,
  //     'scheduledDate': Timestamp.fromDate(scheduledDate),
  //     'completedDate':
  //         completedDate != null ? Timestamp.fromDate(completedDate!) : null,
  //     'status': status.name,
  //     'technician': technician,
  //     'cost': cost,
  //     'notes': notes,
  //     'partsUsed': partsUsed,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //   };
  // }

  bool get isOverdue {
    return status == MaintenanceStatus.scheduled &&
        DateTime.now().isAfter(scheduledDate);
  }

  Duration? get duration {
    if (completedDate == null) return null;
    return completedDate!.difference(scheduledDate);
  }
}

enum MaintenanceType {
  repair,
  cleaning,
  upgrade,
  inspection,
  replacement,
}

enum MaintenanceStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

extension MaintenanceTypeExtension on MaintenanceType {
  String get displayName {
    switch (this) {
      case MaintenanceType.repair:
        return 'Repair';
      case MaintenanceType.cleaning:
        return 'Cleaning';
      case MaintenanceType.upgrade:
        return 'Upgrade';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.replacement:
        return 'Replacement';
    }
  }
}

extension MaintenanceStatusExtension on MaintenanceStatus {
  String get displayName {
    switch (this) {
      case MaintenanceStatus.scheduled:
        return 'Scheduled';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
