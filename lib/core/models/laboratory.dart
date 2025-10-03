// Temporarily disabled for testing without Firebase
// import 'package:cloud_firestore/cloud_firestore.dart';

class Laboratory {
  final String id;
  final String name;
  final String department;
  final String building;
  final String room;
  final int capacity;
  final String description;
  final String? supervisor;
  final List<String> assignedComponents;
  final Map<String, dynamic> equipment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Laboratory({
    required this.id,
    required this.name,
    required this.department,
    required this.building,
    required this.room,
    required this.capacity,
    required this.description,
    this.supervisor,
    required this.assignedComponents,
    required this.equipment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Temporarily disabled Firebase methods for testing
  // factory Laboratory.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return Laboratory(
  //     id: doc.id,
  //     name: data['name'] ?? '',
  //     department: data['department'] ?? '',
  //     building: data['building'] ?? '',
  //     room: data['room'] ?? '',
  //     capacity: data['capacity'] ?? 0,
  //     description: data['description'] ?? '',
  //     supervisor: data['supervisor'],
  //     assignedComponents: List<String>.from(data['assignedComponents'] ?? []),
  //     equipment: Map<String, dynamic>.from(data['equipment'] ?? {}),
  //     isActive: data['isActive'] ?? true,
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'name': name,
  //     'department': department,
  //     'building': building,
  //     'room': room,
  //     'capacity': capacity,
  //     'description': description,
  //     'supervisor': supervisor,
  //     'assignedComponents': assignedComponents,
  //     'equipment': equipment,
  //     'isActive': isActive,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //   };
  // }

  Laboratory copyWith({
    String? name,
    String? department,
    String? building,
    String? room,
    int? capacity,
    String? description,
    String? supervisor,
    List<String>? assignedComponents,
    Map<String, dynamic>? equipment,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Laboratory(
      id: id,
      name: name ?? this.name,
      department: department ?? this.department,
      building: building ?? this.building,
      room: room ?? this.room,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      supervisor: supervisor ?? this.supervisor,
      assignedComponents: assignedComponents ?? this.assignedComponents,
      equipment: equipment ?? this.equipment,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get fullLocation => '$building - $room';

  int get currentOccupancy => assignedComponents.length;

  double get occupancyRate => capacity > 0 ? currentOccupancy / capacity : 0.0;

  bool get isNearCapacity => occupancyRate >= 0.8;
}

class Deployment {
  final String id;
  final String componentId;
  final String laboratoryId;
  final String? userId;
  final DateTime deploymentDate;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final DeploymentStatus status;
  final String purpose;
  final String? notes;
  final String deployedBy;
  final String? returnedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deployment({
    required this.id,
    required this.componentId,
    required this.laboratoryId,
    this.userId,
    required this.deploymentDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    required this.status,
    required this.purpose,
    this.notes,
    required this.deployedBy,
    this.returnedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Temporarily disabled Firebase methods for testing
  // factory Deployment.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return Deployment(
  //     id: doc.id,
  //     componentId: data['componentId'] ?? '',
  //     laboratoryId: data['laboratoryId'] ?? '',
  //     userId: data['userId'],
  //     deploymentDate: (data['deploymentDate'] as Timestamp).toDate(),
  //     expectedReturnDate: data['expectedReturnDate'] != null
  //         ? (data['expectedReturnDate'] as Timestamp).toDate()
  //         : null,
  //     actualReturnDate: data['actualReturnDate'] != null
  //         ? (data['actualReturnDate'] as Timestamp).toDate()
  //         : null,
  //     status: DeploymentStatus.values.firstWhere(
  //       (s) => s.name == data['status'],
  //       orElse: () => DeploymentStatus.active,
  //     ),
  //     purpose: data['purpose'] ?? '',
  //     notes: data['notes'],
  //     deployedBy: data['deployedBy'] ?? '',
  //     returnedBy: data['returnedBy'],
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'componentId': componentId,
  //     'laboratoryId': laboratoryId,
  //     'userId': userId,
  //     'deploymentDate': Timestamp.fromDate(deploymentDate),
  //     'expectedReturnDate': expectedReturnDate != null
  //         ? Timestamp.fromDate(expectedReturnDate!)
  //         : null,
  //     'actualReturnDate': actualReturnDate != null
  //         ? Timestamp.fromDate(actualReturnDate!)
  //         : null,
  //     'status': status.name,
  //     'purpose': purpose,
  //     'notes': notes,
  //     'deployedBy': deployedBy,
  //     'returnedBy': returnedBy,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //   };
  // }

  bool get isOverdue {
    if (expectedReturnDate == null || status != DeploymentStatus.active) {
      return false;
    }
    return DateTime.now().isAfter(expectedReturnDate!);
  }

  Duration? get duration {
    final endDate = actualReturnDate ?? DateTime.now();
    return endDate.difference(deploymentDate);
  }
}

enum DeploymentStatus {
  active,
  returned,
  overdue,
  damaged,
}

extension DeploymentStatusExtension on DeploymentStatus {
  String get displayName {
    switch (this) {
      case DeploymentStatus.active:
        return 'Active';
      case DeploymentStatus.returned:
        return 'Returned';
      case DeploymentStatus.overdue:
        return 'Overdue';
      case DeploymentStatus.damaged:
        return 'Damaged';
    }
  }
}
