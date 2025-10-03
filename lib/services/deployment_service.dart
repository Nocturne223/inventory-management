import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/deployment_models.dart';

class DeploymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _deploymentsCollection =>
      _firestore.collection('deployments');
  CollectionReference get _deploymentHistoryCollection =>
      _firestore.collection('deployment_history');
  CollectionReference get _inventoryItemsCollection =>
      _firestore.collection('inventory_items');

  // Create a new deployment
  Future<String> createDeployment(Deployment deployment) async {
    try {
      // Start a transaction to ensure data consistency
      return await _firestore.runTransaction<String>((transaction) async {
        // Add the deployment
        final deploymentRef = _deploymentsCollection.doc();
        final deploymentData = deployment
            .copyWith(
              updatedAt: DateTime.now(),
            )
            .toMap();

        transaction.set(deploymentRef, deploymentData);

        // Update the inventory item status to 'in-use'
        final itemRef = _inventoryItemsCollection.doc(deployment.itemId);
        transaction.update(itemRef, {
          'status': 'in-use',
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Add deployment history entry
        final historyRef = _deploymentHistoryCollection.doc();
        final historyEntry = DeploymentHistory(
          id: historyRef.id,
          deploymentId: deploymentRef.id,
          action: 'deployed',
          performedBy: deployment.deployedBy,
          newValue: deployment.assignedTo,
          notes: 'Item deployed to ${deployment.assignedTo}',
          timestamp: DateTime.now(),
        );
        transaction.set(historyRef, historyEntry.toMap());

        return deploymentRef.id;
      });
    } catch (e) {
      throw Exception('Failed to create deployment: $e');
    }
  }

  // Get all deployments as a stream
  Stream<List<Deployment>> getDeployments() {
    return _deploymentsCollection
        .orderBy('deployedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get deployments by status
  Stream<List<Deployment>> getDeploymentsByStatus(String status) {
    return _deploymentsCollection
        .where('status', isEqualTo: status)
        .orderBy('deployedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get active deployments
  Stream<List<Deployment>> getActiveDeployments() {
    return getDeploymentsByStatus('active');
  }

  // Get overdue deployments
  Stream<List<Deployment>> getOverdueDeployments() {
    return _deploymentsCollection
        .where('status', isEqualTo: 'active')
        .where('expectedReturnDate', isLessThan: DateTime.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get deployments by department
  Stream<List<Deployment>> getDeploymentsByDepartment(String departmentId) {
    return _deploymentsCollection
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('deployedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get deployments by assignee
  Stream<List<Deployment>> getDeploymentsByAssignee(String assigneeEmail) {
    return _deploymentsCollection
        .where('assigneeEmail', isEqualTo: assigneeEmail)
        .orderBy('deployedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get single deployment
  Future<Deployment?> getDeployment(String deploymentId) async {
    try {
      final doc = await _deploymentsCollection.doc(deploymentId).get();
      if (doc.exists) {
        return Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get deployment: $e');
    }
  }

  // Update deployment
  Future<void> updateDeployment(
      String deploymentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final deploymentRef = _deploymentsCollection.doc(deploymentId);
        final deploymentDoc = await transaction.get(deploymentRef);

        if (!deploymentDoc.exists) {
          throw Exception('Deployment not found');
        }

        final currentData = deploymentDoc.data() as Map<String, dynamic>;
        final updatedData = {
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        transaction.update(deploymentRef, updatedData);

        // Add history entry for significant changes
        if (updates.containsKey('assignedTo') ||
            updates.containsKey('expectedReturnDate') ||
            updates.containsKey('status')) {
          final historyRef = _deploymentHistoryCollection.doc();
          final historyEntry = DeploymentHistory(
            id: historyRef.id,
            deploymentId: deploymentId,
            action: 'updated',
            performedBy: updates['updatedBy'] ?? 'System',
            previousValue: _getRelevantPreviousValue(currentData, updates),
            newValue: _getRelevantNewValue(updates),
            notes: 'Deployment updated',
            timestamp: DateTime.now(),
          );
          transaction.set(historyRef, historyEntry.toMap());
        }
      });
    } catch (e) {
      throw Exception('Failed to update deployment: $e');
    }
  }

  // Return item (complete deployment)
  Future<void> returnItem(String deploymentId, String returnCondition,
      String? returnNotes, String returnedBy) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final deploymentRef = _deploymentsCollection.doc(deploymentId);
        final deploymentDoc = await transaction.get(deploymentRef);

        if (!deploymentDoc.exists) {
          throw Exception('Deployment not found');
        }

        final deploymentData = deploymentDoc.data() as Map<String, dynamic>;
        final itemId = deploymentData['itemId'] as String;

        // Update deployment status
        transaction.update(deploymentRef, {
          'status': 'returned',
          'actualReturnDate': DateTime.now().toIso8601String(),
          'returnCondition': returnCondition,
          'returnNotes': returnNotes,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Update inventory item status based on condition
        String newItemStatus;
        switch (returnCondition.toLowerCase()) {
          case 'good':
            newItemStatus = 'available';
            break;
          case 'damaged':
            newItemStatus = 'maintenance';
            break;
          case 'needs-maintenance':
            newItemStatus = 'maintenance';
            break;
          default:
            newItemStatus = 'available';
        }

        final itemRef = _inventoryItemsCollection.doc(itemId);
        transaction.update(itemRef, {
          'status': newItemStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Add history entry
        final historyRef = _deploymentHistoryCollection.doc();
        final historyEntry = DeploymentHistory(
          id: historyRef.id,
          deploymentId: deploymentId,
          action: 'returned',
          performedBy: returnedBy,
          newValue: returnCondition,
          notes: returnNotes ?? 'Item returned',
          timestamp: DateTime.now(),
        );
        transaction.set(historyRef, historyEntry.toMap());
      });
    } catch (e) {
      throw Exception('Failed to return item: $e');
    }
  }

  // Extend deployment
  Future<void> extendDeployment(String deploymentId, DateTime newReturnDate,
      String extendedBy, String? reason) async {
    try {
      await updateDeployment(deploymentId, {
        'expectedReturnDate': newReturnDate.toIso8601String(),
        'updatedBy': extendedBy,
      });

      // Add specific history entry for extension
      final historyRef = _deploymentHistoryCollection.doc();
      final historyEntry = DeploymentHistory(
        id: historyRef.id,
        deploymentId: deploymentId,
        action: 'extended',
        performedBy: extendedBy,
        newValue: newReturnDate.toIso8601String(),
        notes: reason ?? 'Deployment extended',
        timestamp: DateTime.now(),
      );
      await historyRef.set(historyEntry.toMap());
    } catch (e) {
      throw Exception('Failed to extend deployment: $e');
    }
  }

  // Get deployment history
  Stream<List<DeploymentHistory>> getDeploymentHistory(String deploymentId) {
    return _deploymentHistoryCollection
        .where('deploymentId', isEqualTo: deploymentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeploymentHistory.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get deployment statistics
  Future<Map<String, dynamic>> getDeploymentStats() async {
    try {
      final allDeployments = await _deploymentsCollection.get();
      final activeDeployments = await _deploymentsCollection
          .where('status', isEqualTo: 'active')
          .get();
      final overdueQuery = await _deploymentsCollection
          .where('status', isEqualTo: 'active')
          .where('expectedReturnDate', isLessThan: DateTime.now())
          .get();

      return {
        'totalDeployments': allDeployments.docs.length,
        'activeDeployments': activeDeployments.docs.length,
        'overdueDeployments': overdueQuery.docs.length,
        'returnedDeployments': allDeployments.docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>)['status'] == 'returned')
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get deployment statistics: $e');
    }
  }

  // Search deployments
  Stream<List<Deployment>> searchDeployments(String query) {
    return _deploymentsCollection
        .orderBy('deployedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Deployment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((deployment) =>
                deployment.itemName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                deployment.assignedTo
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                deployment.assigneeEmail
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList());
  }

  // Helper methods
  String _getRelevantPreviousValue(
      Map<String, dynamic> currentData, Map<String, dynamic> updates) {
    if (updates.containsKey('assignedTo')) {
      return currentData['assignedTo']?.toString() ?? '';
    }
    if (updates.containsKey('expectedReturnDate')) {
      return currentData['expectedReturnDate']?.toString() ?? '';
    }
    if (updates.containsKey('status')) {
      return currentData['status']?.toString() ?? '';
    }
    return '';
  }

  String _getRelevantNewValue(Map<String, dynamic> updates) {
    if (updates.containsKey('assignedTo')) {
      return updates['assignedTo']?.toString() ?? '';
    }
    if (updates.containsKey('expectedReturnDate')) {
      return updates['expectedReturnDate']?.toString() ?? '';
    }
    if (updates.containsKey('status')) {
      return updates['status']?.toString() ?? '';
    }
    return '';
  }

  // Delete deployment (admin only)
  Future<void> deleteDeployment(String deploymentId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final deploymentRef = _deploymentsCollection.doc(deploymentId);
        final deploymentDoc = await transaction.get(deploymentRef);

        if (!deploymentDoc.exists) {
          throw Exception('Deployment not found');
        }

        final deploymentData = deploymentDoc.data() as Map<String, dynamic>;
        final itemId = deploymentData['itemId'] as String;

        // Delete deployment
        transaction.delete(deploymentRef);

        // Reset item status to available if it was in-use
        if (deploymentData['status'] == 'active') {
          final itemRef = _inventoryItemsCollection.doc(itemId);
          transaction.update(itemRef, {
            'status': 'available',
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }

        // Delete associated history entries
        final historyDocs = await _deploymentHistoryCollection
            .where('deploymentId', isEqualTo: deploymentId)
            .get();

        for (final doc in historyDocs.docs) {
          transaction.delete(doc.reference);
        }
      });
    } catch (e) {
      throw Exception('Failed to delete deployment: $e');
    }
  }
}
