import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/deployment_service.dart';
import '../../../services/firestore_data_service.dart';
import '../../../core/models/deployment_models.dart';
import '../../../core/models/inventory_models.dart';

// Service Providers
final deploymentServiceProvider = Provider<DeploymentService>((ref) {
  return DeploymentService();
});

// Use centralized Firestore data service
final dataServiceProvider = Provider<FirestoreDataService>((ref) {
  return FirestoreDataService();
});

// Deployment Providers
final deploymentsProvider = StreamProvider<List<Deployment>>((ref) {
  final service = ref.watch(deploymentServiceProvider);
  return service.getDeployments();
});

final activeDeploymentsProvider = StreamProvider<List<Deployment>>((ref) {
  final service = ref.watch(deploymentServiceProvider);
  return service.getActiveDeployments();
});

final overdueDeploymentsProvider = StreamProvider<List<Deployment>>((ref) {
  final service = ref.watch(deploymentServiceProvider);
  return service.getOverdueDeployments();
});

final deploymentProvider =
    FutureProvider.family<Deployment?, String>((ref, id) {
  final service = ref.watch(deploymentServiceProvider);
  return service.getDeployment(id);
});

final deploymentHistoryProvider =
    StreamProvider.family<List<DeploymentHistory>, String>((ref, deploymentId) {
  final service = ref.watch(deploymentServiceProvider);
  return service.getDeploymentHistory(deploymentId);
});

final deploymentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(dataServiceProvider);
  return service.getDeploymentStats();
});

// Available Items for Deployment (items with status 'AVAILABLE')
// Now using centralized Firestore data service
final availableItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(dataServiceProvider);
  return service.getItemsByStatus('AVAILABLE');
});

// Departments and Locations for Deployment - now using real Firestore data
final departmentsProvider = StreamProvider<List<Department>>((ref) {
  final service = ref.watch(dataServiceProvider);
  return service.getDepartments();
});

final locationsProvider = StreamProvider<List<Location>>((ref) {
  final service = ref.watch(dataServiceProvider);
  return service.getLocations();
});

// Filter and Search Providers
final deploymentSearchQueryProvider = StateProvider<String>((ref) => '');
final deploymentStatusFilterProvider = StateProvider<String>((ref) => 'All');
final deploymentDepartmentFilterProvider =
    StateProvider<String>((ref) => 'All');

// Filtered Deployments Provider
final filteredDeploymentsProvider =
    Provider<AsyncValue<List<Deployment>>>((ref) {
  final deploymentsAsync = ref.watch(deploymentsProvider);
  final searchQuery = ref.watch(deploymentSearchQueryProvider);
  final statusFilter = ref.watch(deploymentStatusFilterProvider);
  final departmentFilter = ref.watch(deploymentDepartmentFilterProvider);

  return deploymentsAsync.whenData((deployments) {
    var filteredDeployments = deployments;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredDeployments = filteredDeployments.where((deployment) {
        return deployment.itemName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            deployment.assignedTo
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            deployment.assigneeEmail
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (statusFilter != 'All') {
      if (statusFilter == 'overdue') {
        filteredDeployments = filteredDeployments
            .where((deployment) => deployment.isOverdue)
            .toList();
      } else {
        filteredDeployments = filteredDeployments
            .where((deployment) => deployment.status == statusFilter)
            .toList();
      }
    }

    // Apply department filter
    if (departmentFilter != 'All') {
      filteredDeployments = filteredDeployments
          .where((deployment) => deployment.departmentId == departmentFilter)
          .toList();
    }

    return filteredDeployments;
  });
});

// Form State Providers for Creating/Editing Deployments
class DeploymentFormState {
  final String? selectedItemId;
  final String assignedTo;
  final String assigneeEmail;
  final String? selectedDepartmentId;
  final String? selectedLocationId;
  final DateTime? expectedReturnDate;
  final String notes;
  final bool isLoading;
  final String? error;

  DeploymentFormState({
    this.selectedItemId,
    this.assignedTo = '',
    this.assigneeEmail = '',
    this.selectedDepartmentId,
    this.selectedLocationId,
    this.expectedReturnDate,
    this.notes = '',
    this.isLoading = false,
    this.error,
  });

  DeploymentFormState copyWith({
    String? selectedItemId,
    String? assignedTo,
    String? assigneeEmail,
    String? selectedDepartmentId,
    String? selectedLocationId,
    DateTime? expectedReturnDate,
    String? notes,
    bool? isLoading,
    String? error,
  }) {
    return DeploymentFormState(
      selectedItemId: selectedItemId ?? this.selectedItemId,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeEmail: assigneeEmail ?? this.assigneeEmail,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isValid {
    return selectedItemId != null &&
        assignedTo.isNotEmpty &&
        assigneeEmail.isNotEmpty &&
        selectedDepartmentId != null &&
        selectedLocationId != null;
  }
}

class DeploymentFormNotifier extends StateNotifier<DeploymentFormState> {
  DeploymentFormNotifier() : super(DeploymentFormState());

  void updateSelectedItem(String? itemId) {
    state = state.copyWith(selectedItemId: itemId);
  }

  void updateAssignedTo(String assignedTo) {
    state = state.copyWith(assignedTo: assignedTo);
  }

  void updateAssigneeEmail(String email) {
    state = state.copyWith(assigneeEmail: email);
  }

  void updateDepartment(String? departmentId) {
    state = state.copyWith(selectedDepartmentId: departmentId);
  }

  void updateLocation(String? locationId) {
    state = state.copyWith(selectedLocationId: locationId);
  }

  void updateExpectedReturnDate(DateTime? date) {
    state = state.copyWith(expectedReturnDate: date);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = DeploymentFormState();
  }
}

final deploymentFormProvider =
    StateNotifierProvider<DeploymentFormNotifier, DeploymentFormState>((ref) {
  return DeploymentFormNotifier();
});

// Return Form State
class ReturnFormState {
  final String returnCondition;
  final String returnNotes;
  final bool isLoading;
  final String? error;

  ReturnFormState({
    this.returnCondition = 'good',
    this.returnNotes = '',
    this.isLoading = false,
    this.error,
  });

  ReturnFormState copyWith({
    String? returnCondition,
    String? returnNotes,
    bool? isLoading,
    String? error,
  }) {
    return ReturnFormState(
      returnCondition: returnCondition ?? this.returnCondition,
      returnNotes: returnNotes ?? this.returnNotes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReturnFormNotifier extends StateNotifier<ReturnFormState> {
  ReturnFormNotifier() : super(ReturnFormState());

  void updateReturnCondition(String condition) {
    state = state.copyWith(returnCondition: condition);
  }

  void updateReturnNotes(String notes) {
    state = state.copyWith(returnNotes: notes);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = ReturnFormState();
  }
}

final returnFormProvider =
    StateNotifierProvider<ReturnFormNotifier, ReturnFormState>((ref) {
  return ReturnFormNotifier();
});

// Constants
final deploymentStatusOptions = [
  'All',
  'active',
  'returned',
  'overdue',
];

final returnConditionOptions = [
  'good',
  'damaged',
  'needs-maintenance',
];
