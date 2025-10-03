import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/deployment_models.dart';
import '../core/models/inventory_models.dart';

class LaboratoryOccupancyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculate occupancy data for a specific laboratory
  Future<LaboratoryOccupancyData> getLaboratoryOccupancy(
      String locationId) async {
    try {
      // Get active deployments for this location
      final deploymentsQuery = await _firestore
          .collection('deployments')
          .where('locationId', isEqualTo: locationId)
          .where('status', isEqualTo: 'active')
          .get();

      // Get laboratory details to get capacity
      final locationDoc =
          await _firestore.collection('locations').doc(locationId).get();

      if (!locationDoc.exists) {
        return LaboratoryOccupancyData(
          locationId: locationId,
          capacity: 0,
          occupiedStations: 0,
          occupancyRate: 0.0,
          activeDeployments: [],
        );
      }

      final location = Location.fromMap(locationDoc.data()!, locationDoc.id);
      final activeDeployments = deploymentsQuery.docs
          .map((doc) => Deployment.fromMap(doc.data(), doc.id))
          .toList();

      final occupiedStations = activeDeployments.length;
      final capacity = location.capacity;
      final occupancyRate = capacity > 0 ? occupiedStations / capacity : 0.0;

      return LaboratoryOccupancyData(
        locationId: locationId,
        capacity: capacity,
        occupiedStations: occupiedStations,
        occupancyRate: occupancyRate,
        activeDeployments: activeDeployments,
      );
    } catch (e) {
      print('Error calculating laboratory occupancy: $e');
      return LaboratoryOccupancyData(
        locationId: locationId,
        capacity: 0,
        occupiedStations: 0,
        occupancyRate: 0.0,
        activeDeployments: [],
      );
    }
  }

  /// Get occupancy data for all laboratories
  Future<Map<String, LaboratoryOccupancyData>>
      getAllLaboratoryOccupancy() async {
    try {
      // Get all locations
      final locationsQuery = await _firestore.collection('locations').get();
      final Map<String, LaboratoryOccupancyData> occupancyData = {};

      for (final locationDoc in locationsQuery.docs) {
        final occupancy = await getLaboratoryOccupancy(locationDoc.id);
        occupancyData[locationDoc.id] = occupancy;
      }

      return occupancyData;
    } catch (e) {
      print('Error getting all laboratory occupancy: $e');
      return {};
    }
  }

  /// Stream of occupancy data for real-time updates
  Stream<LaboratoryOccupancyData> watchLaboratoryOccupancy(
      String locationId) async* {
    yield* _firestore
        .collection('deployments')
        .where('locationId', isEqualTo: locationId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((deploymentsSnapshot) async {
      // Get laboratory details
      final locationDoc =
          await _firestore.collection('locations').doc(locationId).get();

      if (!locationDoc.exists) {
        return LaboratoryOccupancyData(
          locationId: locationId,
          capacity: 0,
          occupiedStations: 0,
          occupancyRate: 0.0,
          activeDeployments: [],
        );
      }

      final location = Location.fromMap(locationDoc.data()!, locationDoc.id);
      final activeDeployments = deploymentsSnapshot.docs
          .map((doc) => Deployment.fromMap(doc.data(), doc.id))
          .toList();

      final occupiedStations = activeDeployments.length;
      final capacity = location.capacity;
      final occupancyRate = capacity > 0 ? occupiedStations / capacity : 0.0;

      return LaboratoryOccupancyData(
        locationId: locationId,
        capacity: capacity,
        occupiedStations: occupiedStations,
        occupancyRate: occupancyRate,
        activeDeployments: activeDeployments,
      );
    });
  }
}

/// Data class to hold laboratory occupancy information
class LaboratoryOccupancyData {
  final String locationId;
  final int capacity;
  final int occupiedStations;
  final double occupancyRate;
  final List<Deployment> activeDeployments;

  LaboratoryOccupancyData({
    required this.locationId,
    required this.capacity,
    required this.occupiedStations,
    required this.occupancyRate,
    required this.activeDeployments,
  });

  /// Get occupancy status for UI display
  String get occupancyStatus {
    if (occupancyRate <= 0.5) return 'Low';
    if (occupancyRate <= 0.8) return 'Moderate';
    return 'High';
  }

  /// Get occupancy status color
  String get occupancyStatusColor {
    if (occupancyRate <= 0.5) return 'green';
    if (occupancyRate <= 0.8) return 'orange';
    return 'red';
  }

  /// Get available stations
  int get availableStations => capacity - occupiedStations;

  /// Check if laboratory is at capacity
  bool get isAtCapacity => occupiedStations >= capacity;

  /// Check if laboratory is overbooked
  bool get isOverbooked => occupiedStations > capacity;
}
