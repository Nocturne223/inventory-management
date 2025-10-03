import 'package:cloud_firestore/cloud_firestore.dart';

// Utility function for parsing DateTime (reusing from inventory_models.dart)
DateTime parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

class Deployment {
  final String id;
  final String itemId;
  final String itemName; // Cached for display
  final String assignedTo; // Person or department name
  final String assigneeEmail; // Contact email
  final String departmentId;
  final String locationId;
  final String status; // active, returned, overdue, pending-return
  final DateTime deployedAt;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final String? notes;
  final String? returnCondition; // good, damaged, needs-maintenance
  final String? returnNotes;
  final String deployedBy; // User who initiated deployment
  final DateTime createdAt;
  final DateTime updatedAt;

  Deployment({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.assignedTo,
    required this.assigneeEmail,
    required this.departmentId,
    required this.locationId,
    required this.status,
    required this.deployedAt,
    this.expectedReturnDate,
    this.actualReturnDate,
    this.notes,
    this.returnCondition,
    this.returnNotes,
    required this.deployedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deployment.fromMap(Map<String, dynamic> map, String id) {
    return Deployment(
      id: id,
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      assigneeEmail: map['assigneeEmail'] ?? '',
      departmentId: map['departmentId'] ?? '',
      locationId: map['locationId'] ?? '',
      status: map['status'] ?? 'active',
      deployedAt: parseDateTime(map['deployedAt']),
      expectedReturnDate: map['expectedReturnDate'] != null
          ? parseDateTime(map['expectedReturnDate'])
          : null,
      actualReturnDate: map['actualReturnDate'] != null
          ? parseDateTime(map['actualReturnDate'])
          : null,
      notes: map['notes'],
      returnCondition: map['returnCondition'],
      returnNotes: map['returnNotes'],
      deployedBy: map['deployedBy'] ?? '',
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'assignedTo': assignedTo,
      'assigneeEmail': assigneeEmail,
      'departmentId': departmentId,
      'locationId': locationId,
      'status': status,
      'deployedAt': deployedAt.toIso8601String(),
      'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      'actualReturnDate': actualReturnDate?.toIso8601String(),
      'notes': notes,
      'returnCondition': returnCondition,
      'returnNotes': returnNotes,
      'deployedBy': deployedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Deployment copyWith({
    String? assignedTo,
    String? assigneeEmail,
    String? departmentId,
    String? locationId,
    String? status,
    DateTime? expectedReturnDate,
    DateTime? actualReturnDate,
    String? notes,
    String? returnCondition,
    String? returnNotes,
    DateTime? updatedAt,
  }) {
    return Deployment(
      id: id,
      itemId: itemId,
      itemName: itemName,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeEmail: assigneeEmail ?? this.assigneeEmail,
      departmentId: departmentId ?? this.departmentId,
      locationId: locationId ?? this.locationId,
      status: status ?? this.status,
      deployedAt: deployedAt,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      notes: notes ?? this.notes,
      returnCondition: returnCondition ?? this.returnCondition,
      returnNotes: returnNotes ?? this.returnNotes,
      deployedBy: deployedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods
  bool get isOverdue {
    if (status != 'active' || expectedReturnDate == null) return false;
    return DateTime.now().isAfter(expectedReturnDate!);
  }

  int get daysUntilReturn {
    if (expectedReturnDate == null) return 0;
    return expectedReturnDate!.difference(DateTime.now()).inDays;
  }

  int get deploymentDuration {
    final endDate = actualReturnDate ?? DateTime.now();
    return endDate.difference(deployedAt).inDays;
  }
}

class DeploymentHistory {
  final String id;
  final String deploymentId;
  final String action; // deployed, updated, returned, extended
  final String performedBy;
  final String? previousValue;
  final String? newValue;
  final String? notes;
  final DateTime timestamp;

  DeploymentHistory({
    required this.id,
    required this.deploymentId,
    required this.action,
    required this.performedBy,
    this.previousValue,
    this.newValue,
    this.notes,
    required this.timestamp,
  });

  factory DeploymentHistory.fromMap(Map<String, dynamic> map, String id) {
    return DeploymentHistory(
      id: id,
      deploymentId: map['deploymentId'] ?? '',
      action: map['action'] ?? '',
      performedBy: map['performedBy'] ?? '',
      previousValue: map['previousValue'],
      newValue: map['newValue'],
      notes: map['notes'],
      timestamp: parseDateTime(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deploymentId': deploymentId,
      'action': action,
      'performedBy': performedBy,
      'previousValue': previousValue,
      'newValue': newValue,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
