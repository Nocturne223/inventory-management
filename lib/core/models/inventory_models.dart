import 'package:cloud_firestore/cloud_firestore.dart';

// Utility function to parse DateTime from Firestore data
DateTime parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final String model;
  final String serialNumber;
  final String status; // available, in-use, maintenance, retired
  final double price;
  final DateTime purchaseDate;
  final String? warrantyExpiry;
  final String locationId;
  final String departmentId;
  final Map<String, dynamic>? specifications;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.status,
    required this.price,
    required this.purchaseDate,
    this.warrantyExpiry,
    required this.locationId,
    required this.departmentId,
    this.specifications,
    this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      status: map['status'] ?? 'available',
      price: (map['price'] ?? 0).toDouble(),
      purchaseDate: parseDateTime(map['purchaseDate']),
      warrantyExpiry: map['warrantyExpiry'],
      locationId: map['locationId'] ?? '',
      departmentId: map['departmentId'] ?? '',
      specifications: map['specifications'],
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'status': status,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'warrantyExpiry': warrantyExpiry,
      'locationId': locationId,
      'departmentId': departmentId,
      'specifications': specifications,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? name,
    String? description,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? status,
    double? price,
    DateTime? purchaseDate,
    String? warrantyExpiry,
    String? locationId,
    String? departmentId,
    Map<String, dynamic>? specifications,
    List<String>? images,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      locationId: locationId ?? this.locationId,
      departmentId: departmentId ?? this.departmentId,
      specifications: specifications ?? this.specifications,
      images: images ?? this.images,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class Department {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? headOfDepartment;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.headOfDepartment,
    required this.createdAt,
  });

  factory Department.fromMap(Map<String, dynamic> map, String id) {
    return Department(
      id: id,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      headOfDepartment: map['headOfDepartment'],
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'headOfDepartment': headOfDepartment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Location {
  final String id;
  final String name;
  final String building;
  final String room;
  final String? description;
  final int capacity;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.name,
    required this.building,
    required this.room,
    this.description,
    required this.capacity,
    required this.createdAt,
  });

  factory Location.fromMap(Map<String, dynamic> map, String id) {
    return Location(
      id: id,
      name: map['name'] ?? '',
      building: map['building'] ?? '',
      room: map['room'] ?? '',
      description: map['description'],
      capacity: map['capacity'] ?? 20, // Default capacity
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'room': room,
      'description': description,
      'capacity': capacity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Location copyWith({
    String? name,
    String? building,
    String? room,
    String? description,
    int? capacity,
  }) {
    return Location(
      id: id,
      name: name ?? this.name,
      building: building ?? this.building,
      room: room ?? this.room,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt,
    );
  }
}
