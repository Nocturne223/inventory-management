# User Management System - Test Users Documentation

## Overview

This document contains information about the 10 test users created for the AssetFlow Inventory & Deployment System. These users represent different roles and permission levels for comprehensive testing.

## User Accounts

### 1. SuperAdmin User

- **Email:** `emma.superadmin@mit.edu`
- **Name:** Emma SuperAdmin
- **Role:** SuperAdmin (Highest privileges)
- **Department:** IT Department
- **Phone:** +1-555-0101
- **Status:** Active
- **Special Features:**
  - Full system access
  - User Management access
  - Data Management access
  - 2FA enabled

### 2. Primary Admin User

- **Email:** `john.admin@mit.edu`
- **Name:** John Administrator
- **Role:** Admin
- **Department:** IT Department
- **Phone:** +1-555-0102
- **Status:** Active
- **Features:**
  - Administrative privileges
  - User management (limited)
  - 2FA enabled

### 3. Secondary Admin User

- **Email:** `robert.admin@mit.edu`
- **Name:** Robert Davis
- **Role:** Admin
- **Department:** System Administration
- **Phone:** +1-555-0109
- **Status:** Active
- **Features:**
  - Administrative privileges
  - User management (limited)
  - 2FA enabled

### 4. Engineering Manager

- **Email:** `sarah.manager@mit.edu`
- **Name:** Sarah Johnson
- **Role:** Manager
- **Department:** Engineering Department
- **Phone:** +1-555-0103
- **Status:** Active
- **Features:**
  - Department management
  - Laboratory management
  - Reporting access

### 5. Research Manager

- **Email:** `maria.manager@mit.edu`
- **Name:** Maria Rodriguez
- **Role:** Manager
- **Department:** Research Department
- **Phone:** +1-555-0108
- **Status:** Active
- **Features:**
  - Research department oversight
  - Laboratory management
  - Analytics access

### 6. Technical Support Technician

- **Email:** `mike.tech@mit.edu`
- **Name:** Mike Thompson
- **Role:** Technician
- **Department:** Technical Support
- **Phone:** +1-555-0104
- **Status:** Active
- **Features:**
  - Equipment maintenance
  - Component management
  - Deployment handling

### 7. Hardware Maintenance Technician

- **Email:** `lisa.tech@mit.edu`
- **Name:** Lisa Chen
- **Role:** Technician
- **Department:** Hardware Maintenance
- **Phone:** +1-555-0105
- **Status:** Active
- **Features:**
  - Hardware maintenance
  - Equipment repairs
  - Component tracking

### 8. Computer Science User

- **Email:** `jane.user@mit.edu`
- **Name:** Jane Smith
- **Role:** User (Standard)
- **Department:** Computer Science
- **Phone:** +1-555-0106
- **Status:** Active
- **Features:**
  - Basic system access
  - Equipment requests
  - View permissions only

### 9. Mathematics User

- **Email:** `david.user@mit.edu`
- **Name:** David Wilson
- **Role:** User (Standard)
- **Department:** Mathematics
- **Phone:** +1-555-0107
- **Status:** Active
- **Features:**
  - Basic system access
  - Equipment requests
  - View permissions only

### 10. Test Inactive User

- **Email:** `inactive.user@mit.edu`
- **Name:** Inactive User
- **Role:** User (Standard)
- **Department:** Test Department
- **Phone:** +1-555-0110
- **Status:** **INACTIVE**
- **Purpose:** Testing inactive user scenarios

## Role Hierarchy & Permissions

### SuperAdmin (Level 5)

- **Full System Control**
- **Permissions:**
  - All component operations (create, edit, delete)
  - User management (full access)
  - System configuration
  - Data management
  - Backup/restore
  - All laboratory operations
  - Analytics and reporting
  - Maintenance management

### Admin (Level 4)

- **Administrative Control**
- **Permissions:**
  - All component operations (create, edit, delete)
  - User management (limited)
  - Laboratory management
  - Analytics and reporting
  - Maintenance management
  - Deployment management

### Manager (Level 3)

- **Department Oversight**
- **Permissions:**
  - Component operations (create, edit)
  - Laboratory management
  - Analytics access
  - Deployment management
  - Maintenance coordination
  - Report generation

### Technician (Level 2)

- **Technical Operations**
- **Permissions:**
  - Component operations (create, edit)
  - Deployment handling
  - Maintenance management
  - Equipment tracking

### User (Level 1)

- **Basic Access**
- **Permissions:**
  - View components
  - Request equipment
  - Basic system navigation

## Authentication Setup

### Firebase Authentication

Since we're using Firebase Authentication, you'll need to create the corresponding authentication accounts:

1. **Go to Firebase Console**
2. **Navigate to Authentication > Users**
3. **Create accounts for each user:**
   - Use the email addresses listed above
   - Set temporary passwords (users can reset)
   - Match the UIDs when possible

### Recommended Authentication Flow

```
1. Create Firebase Auth accounts with emails above
2. Run the seeding script: `dart tools/seed_10_users.dart`
3. Users can sign in with their email and reset password
4. System will match Firebase Auth UID with Firestore user data
```

## Testing Scenarios

### Role-Based Access Testing

- **SuperAdmin:** Test user management, data management access
- **Admin:** Test administrative functions, limited user access
- **Manager:** Test department oversight, laboratory management
- **Technician:** Test equipment operations, maintenance
- **User:** Test basic access, view-only permissions
- **Inactive:** Test account deactivation scenarios

### Department-Based Testing

- **IT Department:** SuperAdmin, Primary Admin
- **Engineering:** Manager oversight
- **Research:** Research operations
- **Technical Support:** Equipment maintenance
- **Academic Departments:** End-user scenarios

### Permission Testing

- **Create/Edit/Delete:** Test based on role levels
- **Laboratory Management:** Admin+ roles
- **User Management:** SuperAdmin only
- **Analytics:** Manager+ roles
- **Maintenance:** Technician+ roles

## Security Features

### Two-Factor Authentication

- **Enabled for:** SuperAdmin, Admin users
- **Purpose:** Enhanced security for privileged accounts

### Account Status Management

- **Active Users:** 9 users for normal operations
- **Inactive User:** 1 user for testing deactivation

### Permission Matrix

| Permission        | SuperAdmin | Admin | Manager | Technician | User |
| ----------------- | ---------- | ----- | ------- | ---------- | ---- |
| View Components   | ✅         | ✅    | ✅      | ✅         | ✅   |
| Create Components | ✅         | ✅    | ✅      | ✅         | ❌   |
| Edit Components   | ✅         | ✅    | ✅      | ✅         | ❌   |
| Delete Components | ✅         | ✅    | ❌      | ❌         | ❌   |
| Manage Users      | ✅         | ✅    | ❌      | ❌         | ❌   |
| Data Management   | ✅         | ❌    | ❌      | ❌         | ❌   |
| Laboratory Mgmt   | ✅         | ✅    | ✅      | ❌         | ❌   |
| Analytics         | ✅         | ✅    | ✅      | ❌         | ❌   |
| Maintenance       | ✅         | ✅    | ✅      | ✅         | ❌   |
| Deployments       | ✅         | ✅    | ✅      | ✅         | ❌   |

## Usage Instructions

### Running the Seeding Script

```bash
cd tools
dart seed_10_users.dart
```

### Verifying User Creation

1. Check Firestore Console
2. Navigate to `users` collection
3. Verify all 10 users are created
4. Check role distribution and permissions

### Testing Login Flow

1. Create Firebase Auth accounts matching the emails
2. Test login with different roles
3. Verify role-based UI changes
4. Test permission restrictions

## Notes

- **No passwords** are stored in Firestore (Firebase Auth handles authentication)
- **UIDs** are included for Firebase Auth matching
- **Phone numbers** use placeholder format
- **Profile images** are set to null (can be added later)
- **Login tracking** includes realistic last login times
- **Departments** represent different organizational units

This setup provides comprehensive testing coverage for all role-based features and user management scenarios in the AssetFlow Inventory & Deployment System.
