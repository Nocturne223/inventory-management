# Deployment Approval Workflow Implementation Plan

## 🎯 Overview

This document outlines the implementation of a **Request → Approval → Deploy** workflow system where lower-level roles can submit deployment requests that require approval from higher-level roles before execution.

---

## 🏗️ Current vs Proposed Workflow

### Current Direct Deployment Flow

```
User (any role) → Create Deployment → Item Deployed → Active Status
```

### Proposed Approval Workflow

```
User/Technician → Submit Request → Manager/Admin Review → Approve/Reject → Deploy/Notify
```

---

## 📊 Role-Based Request & Approval Matrix

| **Role**       |   **Can Request**    |       **Can Approve**       | **Approval Level** | **Auto-Approve Limit** |
| -------------- | :------------------: | :-------------------------: | :----------------: | :--------------------: |
| **User**       |  ✅ Basic requests   |             ❌              |         -          |          None          |
| **Technician** | ✅ Standard requests |             ❌              |         -          |         < $500         |
| **Manager**    |   ✅ All requests    | ✅ User/Technician requests |      Level 1       |        < $2,000        |
| **Admin**      |   ✅ All requests    |       ✅ All requests       |      Level 2       |        < $5,000        |
| **SuperAdmin** |   ✅ All requests    |       ✅ All requests       |      Level 3       |       Unlimited        |

### Approval Rules

1. **Basic Equipment** (< $500): Auto-approved for Technicians+
2. **Standard Equipment** ($500 - $2,000): Manager approval required
3. **High-Value Equipment** ($2,000 - $5,000): Admin approval required
4. **Critical/Expensive** (> $5,000): SuperAdmin approval required
5. **Emergency Requests**: Expedited approval process with post-approval review

---

## 🔧 Technical Implementation

### 1. New Models Required

#### DeploymentRequest Model

```dart
class DeploymentRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String itemId;
  final String itemName;
  final double itemValue;
  final String assignedTo;
  final String assigneeEmail;
  final String departmentId;
  final String locationId;
  final RequestStatus status;
  final RequestPriority priority;
  final String justification;
  final DateTime? expectedReturnDate;
  final String? notes;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? approverNotes;
  final String? rejectionReason;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum RequestStatus {
  pending,           // Waiting for approval
  approved,          // Approved, ready for deployment
  rejected,          // Rejected by approver
  deployed,          // Successfully deployed
  cancelled,         // Cancelled by requester
  expired,           // Request expired without action
}

enum RequestPriority {
  low,
  normal,
  high,
  emergency,
}
```

#### ApprovalWorkflow Model

```dart
class ApprovalWorkflow {
  final String id;
  final String requestId;
  final String approverId;
  final String approverName;
  final WorkflowAction action;
  final String? comments;
  final DateTime timestamp;
  final String? previousStatus;
  final String newStatus;
}

enum WorkflowAction {
  submitted,
  approved,
  rejected,
  deployed,
  cancelled,
  escalated,
}
```

### 2. Updated Deployment Model

```dart
class Deployment {
  // ... existing fields ...
  final String? originalRequestId;  // Link back to request
  final String? approvedBy;         // Who approved the request
  final DateTime? approvedAt;       // When it was approved
  // ... rest of existing fields ...
}
```

---

## 🎨 User Interface Changes

### 1. For Requesters (User/Technician)

- **Request Submission Form**
  - Item selection with value display
  - Justification field (required for high-value items)
  - Priority selection
  - Emergency flag option
- **My Requests Dashboard**
  - Pending requests status
  - Request history
  - Ability to cancel pending requests

### 2. For Approvers (Manager/Admin/SuperAdmin)

- **Approval Queue Dashboard**
  - Pending requests requiring their approval
  - Request details with item value and justification
  - Quick approve/reject actions
  - Bulk approval for multiple small requests
- **Approval History**
  - Track all approval decisions
  - Performance metrics

### 3. Enhanced Notifications

- **Email/In-App Notifications for:**
  - New requests requiring approval
  - Request status updates (approved/rejected)
  - Deployment completion confirmations
  - Escalation alerts for overdue approvals

---

## 🔄 Workflow Logic Implementation

### 1. Request Submission Logic

```dart
class DeploymentRequestService {
  Future<String> submitRequest(DeploymentRequest request) async {
    // 1. Validate requester permissions
    final requester = await getUserById(request.requesterId);
    if (!canSubmitRequest(requester.role, request.itemValue)) {
      throw UnauthorizedException('Insufficient permissions');
    }

    // 2. Check auto-approval eligibility
    if (isAutoApprovalEligible(requester.role, request.itemValue)) {
      return await autoApproveRequest(request);
    }

    // 3. Determine required approval level
    final approvalLevel = getRequiredApprovalLevel(request.itemValue);
    final approvers = await getEligibleApprovers(approvalLevel, request.departmentId);

    // 4. Submit for approval
    await createRequest(request);
    await notifyApprovers(approvers, request);

    return request.id;
  }
}
```

### 2. Approval Processing Logic

```dart
class ApprovalService {
  Future<void> processApproval(String requestId, String approverId,
                              ApprovalDecision decision) async {
    final request = await getRequestById(requestId);
    final approver = await getUserById(approverId);

    // Validate approval authority
    if (!canApproveRequest(approver.role, request.itemValue)) {
      throw UnauthorizedException('Insufficient approval authority');
    }

    if (decision.action == ApprovalAction.approve) {
      await approveRequest(request, approver, decision.comments);
      await createDeployment(request);
      await notifyRequester(request, 'approved');
    } else {
      await rejectRequest(request, approver, decision.reason);
      await notifyRequester(request, 'rejected');
    }

    await logApprovalAction(request, approver, decision);
  }
}
```

### 3. Auto-Approval Logic

```dart
bool isAutoApprovalEligible(UserRole role, double itemValue) {
  switch (role) {
    case UserRole.technician:
      return itemValue < 500;
    case UserRole.manager:
      return itemValue < 2000;
    case UserRole.admin:
      return itemValue < 5000;
    case UserRole.superAdmin:
      return true;
    default:
      return false;
  }
}
```

---

## 📋 Database Schema Changes

### 1. New Collections

#### deployment_requests

```json
{
  "id": "req_001",
  "requesterId": "user_123",
  "requesterName": "John Smith",
  "requesterEmail": "john.smith@mit.edu",
  "itemId": "item_456",
  "itemName": "MacBook Pro 16-inch",
  "itemValue": 2499.99,
  "assignedTo": "Research Lab A",
  "assigneeEmail": "lab-a@mit.edu",
  "departmentId": "dept_cs",
  "locationId": "building_32",
  "status": "pending",
  "priority": "normal",
  "justification": "Needed for machine learning research project",
  "expectedReturnDate": "2025-12-01T00:00:00Z",
  "notes": "Requires specific software installation",
  "requestedAt": "2025-10-04T10:00:00Z",
  "approvedAt": null,
  "approvedBy": null,
  "approverNotes": null,
  "rejectionReason": null,
  "isEmergency": false,
  "createdAt": "2025-10-04T10:00:00Z",
  "updatedAt": "2025-10-04T10:00:00Z"
}
```

#### approval_workflows

```json
{
  "id": "workflow_001",
  "requestId": "req_001",
  "approverId": "manager_001",
  "approverName": "Sarah Johnson",
  "action": "approved",
  "comments": "Approved for research project. Please ensure proper handling.",
  "timestamp": "2025-10-04T11:30:00Z",
  "previousStatus": "pending",
  "newStatus": "approved"
}
```

### 2. Updated Collections

#### deployments (add fields)

```json
{
  // ... existing fields ...
  "originalRequestId": "req_001",
  "approvedBy": "manager_001",
  "approvedAt": "2025-10-04T11:30:00Z"
}
```

---

## 🎯 Implementation Phases

### Phase 1: Foundation (Week 1-2)

1. **Database Schema Updates**

   - Create new collections and indexes
   - Update existing deployment model
   - Set up migration scripts

2. **Core Models & Services**
   - Implement DeploymentRequest model
   - Create ApprovalWorkflow model
   - Build DeploymentRequestService
   - Build ApprovalService

### Phase 2: Business Logic (Week 3-4)

1. **Approval Engine**

   - Implement approval level determination
   - Build auto-approval logic
   - Create escalation handling
   - Add permission validation

2. **Notification System**
   - Email notifications for approvers
   - In-app notification system
   - Real-time updates via WebSocket

### Phase 3: User Interface (Week 5-6)

1. **Request Submission UI**

   - Request creation form
   - Item value display and warnings
   - Justification requirements

2. **Approval Dashboard**
   - Pending requests queue
   - Quick approval actions
   - Request details modal

### Phase 4: Integration & Testing (Week 7-8)

1. **System Integration**

   - Connect with existing deployment system
   - Update role-based permissions
   - Implement audit logging

2. **Testing & Validation**
   - Unit tests for approval logic
   - Integration tests for workflows
   - User acceptance testing

---

## 🔐 Security & Compliance Features

### 1. Audit Trail

- Complete request lifecycle logging
- Approval decision tracking
- User action history
- Compliance reporting

### 2. Role-Based Security

- Request submission permissions
- Approval authority validation
- Department-based restrictions
- Emergency access controls

### 3. Data Validation

- Item value verification
- User authentication
- Request duplicate prevention
- Approval timeout handling

---

## 📊 Benefits of This Implementation

### 1. **Improved Governance**

- Clear approval process for all deployments
- Audit trail for compliance requirements
- Controlled access to high-value equipment

### 2. **Better Cost Control**

- Value-based approval thresholds
- Justification requirements for expensive items
- Visibility into deployment costs

### 3. **Enhanced Security**

- Reduced risk of unauthorized deployments
- Separation of duties between request and approval
- Emergency access with proper oversight

### 4. **Operational Efficiency**

- Auto-approval for routine requests
- Streamlined approval process
- Clear escalation paths

---

## 🚀 Getting Started

Would you like me to:

1. **Start with the database models** - Create the new DeploymentRequest and ApprovalWorkflow models
2. **Build the approval service** - Implement the core approval logic and workflows
3. **Create the request submission UI** - Build the user interface for submitting requests
4. **Set up the approval dashboard** - Create the interface for managers/admins to review requests

This approval workflow system would transform your inventory management into a enterprise-grade solution with proper governance, security, and compliance capabilities while maintaining operational efficiency through smart auto-approval rules.
