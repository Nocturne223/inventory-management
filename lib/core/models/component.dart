// Temporarily disabled for testing without Firebase
// import 'package:cloud_firestore/cloud_firestore.dart';

class Component {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String model;
  final String serialNumber;
  final String assetTag;
  final ComponentStatus status;
  final DateTime acquisitionDate;
  final double acquisitionCost;
  final String? description;
  final Map<String, dynamic> specifications;
  final String? imageUrl;
  final String? qrCode;
  final String? location;
  final String? assignedTo;
  final DateTime? deploymentDate;
  final DateTime? warrantyExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Component({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.assetTag,
    required this.status,
    required this.acquisitionDate,
    required this.acquisitionCost,
    this.description,
    required this.specifications,
    this.imageUrl,
    this.qrCode,
    this.location,
    this.assignedTo,
    this.deploymentDate,
    this.warrantyExpiry,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Temporarily disabled Firebase methods for testing
  // factory Component.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return Component(
  //     id: doc.id,
  //     name: data['name'] ?? '',
  //     category: data['category'] ?? '',
  //     brand: data['brand'] ?? '',
  //     model: data['model'] ?? '',
  //     serialNumber: data['serialNumber'] ?? '',
  //     assetTag: data['assetTag'] ?? '',
  //     status: ComponentStatus.values.firstWhere(
  //       (s) => s.name == data['status'],
  //       orElse: () => ComponentStatus.available,
  //     ),
  //     acquisitionDate: (data['acquisitionDate'] as Timestamp).toDate(),
  //     acquisitionCost: (data['acquisitionCost'] ?? 0.0).toDouble(),
  //     description: data['description'],
  //     specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
  //     imageUrl: data['imageUrl'],
  //     qrCode: data['qrCode'],
  //     location: data['location'],
  //     assignedTo: data['assignedTo'],
  //     deploymentDate: data['deploymentDate'] != null
  //         ? (data['deploymentDate'] as Timestamp).toDate()
  //         : null,
  //     warrantyExpiry: data['warrantyExpiry'] != null
  //         ? (data['warrantyExpiry'] as Timestamp).toDate()
  //         : null,
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  //     createdBy: data['createdBy'] ?? '',
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'name': name,
  //     'category': category,
  //     'brand': brand,
  //     'model': model,
  //     'serialNumber': serialNumber,
  //     'assetTag': assetTag,
  //     'status': status.name,
  //     'acquisitionDate': Timestamp.fromDate(acquisitionDate),
  //     'acquisitionCost': acquisitionCost,
  //     'description': description,
  //     'specifications': specifications,
  //     'imageUrl': imageUrl,
  //     'qrCode': qrCode,
  //     'location': location,
  //     'assignedTo': assignedTo,
  //     'deploymentDate':
  //         deploymentDate != null ? Timestamp.fromDate(deploymentDate!) : null,
  //     'warrantyExpiry':
  //         warrantyExpiry != null ? Timestamp.fromDate(warrantyExpiry!) : null,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //     'createdBy': createdBy,
  //   };
  // }

  Component copyWith({
    String? name,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? assetTag,
    ComponentStatus? status,
    DateTime? acquisitionDate,
    double? acquisitionCost,
    String? description,
    Map<String, dynamic>? specifications,
    String? imageUrl,
    String? qrCode,
    String? location,
    String? assignedTo,
    DateTime? deploymentDate,
    DateTime? warrantyExpiry,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Component(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      assetTag: assetTag ?? this.assetTag,
      status: status ?? this.status,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      imageUrl: imageUrl ?? this.imageUrl,
      qrCode: qrCode ?? this.qrCode,
      location: location ?? this.location,
      assignedTo: assignedTo ?? this.assignedTo,
      deploymentDate: deploymentDate ?? this.deploymentDate,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum ComponentStatus {
  available,
  deployed,
  maintenance,
  damaged,
  disposed,
}

extension ComponentStatusExtension on ComponentStatus {
  String get displayName {
    switch (this) {
      case ComponentStatus.available:
        return 'Available';
      case ComponentStatus.deployed:
        return 'Deployed';
      case ComponentStatus.maintenance:
        return 'Maintenance';
      case ComponentStatus.damaged:
        return 'Damaged';
      case ComponentStatus.disposed:
        return 'Disposed';
    }
  }

  String get description {
    switch (this) {
      case ComponentStatus.available:
        return 'Ready for deployment';
      case ComponentStatus.deployed:
        return 'Currently in use';
      case ComponentStatus.maintenance:
        return 'Under maintenance';
      case ComponentStatus.damaged:
        return 'Needs repair';
      case ComponentStatus.disposed:
        return 'No longer in use';
    }
  }
}
