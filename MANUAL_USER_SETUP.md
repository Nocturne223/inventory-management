# Manual User Creation Guide for Firebase

Since the automated scripts are having permission issues, here's a manual guide to create users with different roles in your Firebase console:

## Step 1: Go to Firebase Console

1. Open https://console.firebase.google.com
2. Select your project "inventory-management-aefea"
3. Go to "Firestore Database"

## Step 2: Create Users Collection Documents

Navigate to the "users" collection and create these documents manually:

### 1. Admin User (existing)

**Document ID:** `APduHk4yn8TL1W9oahqYI0w4efU2`

```json
{
  "email": "admin@mit.edu",
  "name": "System Administrator",
  "role": "Admin",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": "2024-12-19T10:00:00.000Z",
  "isActive": true
}
```

### 2. Tech User 1

**Document ID:** `tech_user_001`

```json
{
  "email": "tech1@mit.edu",
  "name": "Technical Support 1",
  "role": "Tech",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 3. Tech User 2

**Document ID:** `tech_user_002`

```json
{
  "email": "tech2@mit.edu",
  "name": "Technical Support 2",
  "role": "Tech",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 4. GSO User 1

**Document ID:** `gso_user_001`

```json
{
  "email": "gso1@mit.edu",
  "name": "General Services Officer 1",
  "role": "GSO",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 5. GSO User 2

**Document ID:** `gso_user_002`

```json
{
  "email": "gso2@mit.edu",
  "name": "General Services Officer 2",
  "role": "GSO",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 6. MIS User

**Document ID:** `mis_user_001`

```json
{
  "email": "mis@mit.edu",
  "name": "Management Information Systems",
  "role": "MIS",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 7. Admin User 2

**Document ID:** `admin_user_002`

```json
{
  "email": "admin2@mit.edu",
  "name": "Department Administrator",
  "role": "Admin",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 8. SuperAdmin User

**Document ID:** `superadmin_user_001`

```json
{
  "email": "superadmin@mit.edu",
  "name": "Super Administrator",
  "role": "SuperAdmin",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": true
}
```

### 9. Inactive User (for testing)

**Document ID:** `inactive_user_001`

```json
{
  "email": "inactive@mit.edu",
  "name": "Inactive User",
  "role": "Tech",
  "createdAt": "2024-12-19T10:00:00.000Z",
  "lastLoginAt": null,
  "isActive": false
}
```

## Step 3: Create Authentication Users (Optional)

If you want to test login functionality:

1. Go to "Authentication" > "Users"
2. Add users with the same emails as above
3. Set temporary passwords (users can reset them)

## Role Summary:

- **Tech**: 3 users (including 1 inactive)
- **GSO**: 2 users
- **MIS**: 1 user
- **Admin**: 2 users
- **SuperAdmin**: 1 user
- **Total**: 9 users (8 active, 1 inactive)

## Testing:

You can now test the application with the existing authenticated user `admin@mit.edu` and implement role-based features based on the user's role field.
