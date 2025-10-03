# How to Execute the User Seeding Script

## Overview

The user seeding script creates 10 diverse test users for the AssetFlow Inventory & Deployment System with proper role distribution and permissions.

## Quick Execution

### Method 1: Standalone Script (Recommended - No Flutter Dependencies)

```powershell
cd "C:\Users\ealbe\Desktop\MIT\MIT503\dart-inventory-system\beta\inventory-management\tools"
dart standalone_seed_users.dart
```

This script:

- ✅ **Works independently** (no Flutter/Firebase dependencies)
- ✅ **Generates user data** in JSON format
- ✅ **Creates detailed output** for manual import
- ✅ **Provides import instructions**

### Method 2: Firebase-Integrated Script (Requires Firebase Setup)

```powershell
cd "C:\Users\ealbe\Desktop\MIT\MIT503\dart-inventory-system\beta\inventory-management\tools"
dart seed_10_users.dart
```

This script:

- 🔧 Requires proper Firebase configuration
- 🔧 Directly writes to Firestore database
- ⚠️ May have dependency issues with current Flutter setup

## What Gets Created

### 10 Users with Role Distribution:

1. **SuperAdmin (1 user):**

   - emma.superadmin@mit.edu
   - Full system access including User Management
   - 13 permissions

2. **Admin (2 users):**

   - john.admin@mit.edu
   - robert.admin@mit.edu
   - Administrative privileges
   - 9 permissions each

3. **Manager (2 users):**

   - sarah.manager@mit.edu (Engineering)
   - maria.manager@mit.edu (Research)
   - Department oversight
   - 7 permissions each

4. **Technician (2 users):**

   - mike.tech@mit.edu (Technical Support)
   - lisa.tech@mit.edu (Hardware Maintenance)
   - Equipment operations
   - 4 permissions each

5. **User (2 users):**

   - jane.user@mit.edu (Computer Science)
   - david.user@mit.edu (Mathematics)
   - Basic access
   - 1 permission each

6. **Inactive User (1 user):**
   - inactive.user@mit.edu
   - For testing deactivation scenarios
   - 1 permission

## Output Files

### `seeded_users.json`

- Complete user data structure
- Ready for Firebase import
- Includes metadata and timestamps
- Professional formatting

### Console Output

- Detailed user summary
- Role distribution overview
- Import instructions
- Success confirmation

## Manual Firebase Import Process

### 1. Access Firebase Console

- Go to [Firebase Console](https://console.firebase.google.com/)
- Select your project: `inventory-management-8fb2e`

### 2. Navigate to Firestore

- Click on "Firestore Database"
- Go to the `users` collection (create if doesn't exist)

### 3. Import User Data

- Use the generated `seeded_users.json` file
- Import each user as a document
- Use the `uid` field as the document ID

### 4. Create Firebase Authentication Accounts

- Go to Authentication → Users
- Create accounts for each email:
  - emma.superadmin@mit.edu
  - john.admin@mit.edu
  - robert.admin@mit.edu
  - sarah.manager@mit.edu
  - maria.manager@mit.edu
  - mike.tech@mit.edu
  - lisa.tech@mit.edu
  - jane.user@mit.edu
  - david.user@mit.edu
  - inactive.user@mit.edu
- Set temporary passwords (users can reset)
- Match UIDs when possible

## Testing the User Management System

### Login as SuperAdmin

1. Login with: `emma.superadmin@mit.edu`
2. Navigate to dashboard
3. Click the admin tools popup (top-right)
4. Select "User Management"
5. Verify all 10 users appear
6. Test search and filter functionality

### Test Role-Based Access

1. Login with different role levels
2. Verify dashboard admin tools visibility:
   - **SuperAdmin:** Admin tools visible
   - **All others:** Admin tools hidden
3. Test permission restrictions
4. Verify User Management access (SuperAdmin only)

## Troubleshooting

### If dart command fails:

```powershell
# Check Dart installation
dart --version

# If not installed, install Flutter SDK which includes Dart
```

### If Firebase script fails:

- Use the standalone script instead
- Import data manually using the JSON file
- Check Firebase configuration in `firebase_options.dart`

### If users don't appear in UI:

- Check Firestore rules allow read access
- Verify user data structure matches the User model
- Check authentication status

## Success Verification

After execution, you should see:

- ✅ Console output showing 10 users created
- ✅ `seeded_users.json` file generated
- ✅ Detailed role distribution summary
- ✅ Import instructions provided

The system is now ready for comprehensive User Management testing with diverse role-based scenarios!

## Next Steps

1. **Execute the seeding script** using the standalone method
2. **Import data to Firebase** following the manual process
3. **Test User Management system** with SuperAdmin account
4. **Verify role-based access** across different user types
5. **Test authentication flow** with different accounts

This setup provides comprehensive coverage for testing all User Management features and role-based access control scenarios.
