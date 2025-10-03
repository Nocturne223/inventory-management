import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/laboratory_occupancy_service.dart';

// Laboratory Occupancy Service Provider
final laboratoryOccupancyServiceProvider = Provider<LaboratoryOccupancyService>(
  (ref) => LaboratoryOccupancyService(),
);

// Provider to get occupancy for a specific laboratory
final laboratoryOccupancyProvider =
    StreamProvider.family<LaboratoryOccupancyData, String>(
  (ref, locationId) {
    final service = ref.watch(laboratoryOccupancyServiceProvider);
    return service.watchLaboratoryOccupancy(locationId);
  },
);

// Provider to get all laboratory occupancy data
final allLaboratoryOccupancyProvider =
    FutureProvider<Map<String, LaboratoryOccupancyData>>(
  (ref) async {
    final service = ref.watch(laboratoryOccupancyServiceProvider);
    return service.getAllLaboratoryOccupancy();
  },
);
