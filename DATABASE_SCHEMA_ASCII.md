# AssetFlow Database Schema - ASCII Visualization

## Firestore Collections Overview

```
AssetFlow Database (Cloud Firestore)
│
├── users/
│   ├── {userId}
│   │   ├── uid: string
│   │   ├── email: string
│   │   ├── displayName: string
│   │   ├── role: string (SuperAdmin|Admin|Manager|User)
│   │   ├── department: string
│   │   ├── createdAt: timestamp
│   │   ├── lastLogin: timestamp
│   │   └── isActive: boolean
│   │
├── items/
│   ├── {itemId}
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── serialNumber: string
│   │   ├── assetTag: string
│   │   ├── categoryId: string (ref: categories)
│   │   ├── locationId: string (ref: locations)
│   │   ├── departmentId: string (ref: departments)
│   │   ├── status: string (Available|Deployed|Maintenance|Retired)
│   │   ├── purchaseDate: timestamp
│   │   ├── warrantyExpiry: timestamp
│   │   ├── value: number
│   │   ├── qrCode: string
│   │   ├── specifications: map
│   │   ├── createdAt: timestamp
│   │   ├── updatedAt: timestamp
│   │   └── createdBy: string (ref: users)
│   │
├── categories/
│   ├── {categoryId}
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── icon: string
│   │   ├── color: string
│   │   ├── isActive: boolean
│   │   ├── createdAt: timestamp
│   │   └── createdBy: string (ref: users)
│   │
├── departments/
│   ├── {departmentId}
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── head: string (ref: users)
│   │   ├── budget: number
│   │   ├── isActive: boolean
│   │   ├── createdAt: timestamp
│   │   └── createdBy: string (ref: users)
│   │
├── locations/
│   ├── {locationId}
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── type: string (Laboratory|Office|Storage|Classroom)
│   │   ├── capacity: number
│   │   ├── departmentId: string (ref: departments)
│   │   ├── isActive: boolean
│   │   ├── coordinates: geopoint
│   │   ├── createdAt: timestamp
│   │   └── createdBy: string (ref: users)
│   │
├── deployments/
│   ├── {deploymentId}
│   │   ├── itemId: string (ref: items)
│   │   ├── userId: string (ref: users)
│   │   ├── locationId: string (ref: locations)
│   │   ├── deployedBy: string (ref: users)
│   │   ├── deploymentDate: timestamp
│   │   ├── expectedReturnDate: timestamp
│   │   ├── actualReturnDate: timestamp
│   │   ├── status: string (Active|Returned|Overdue|Lost)
│   │   ├── purpose: string
│   │   ├── notes: string
│   │   ├── condition: string (Excellent|Good|Fair|Poor)
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   │
└── maintenance/
    ├── {maintenanceId}
    │   ├── itemId: string (ref: items)
    │   ├── type: string (Preventive|Corrective|Emergency)
    │   ├── description: string
    │   ├── scheduledDate: timestamp
    │   ├── completedDate: timestamp
    │   ├── technician: string (ref: users)
    │   ├── cost: number
    │   ├── status: string (Scheduled|InProgress|Completed|Cancelled)
    │   ├── priority: string (Low|Medium|High|Critical)
    │   ├── notes: string
    │   ├── createdAt: timestamp
    │   └── createdBy: string (ref: users)
```

## Entity Relationship Diagram (ASCII)

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     USERS       │       │   DEPARTMENTS   │       │   LOCATIONS     │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ uid (PK)        │       │ departmentId(PK)│       │ locationId (PK) │
│ email           │◄──────┤ head (FK)       │◄──────┤ departmentId(FK)│
│ displayName     │       │ name            │       │ name            │
│ role            │       │ description     │       │ type            │
│ department      │       │ budget          │       │ capacity        │
│ createdAt       │       │ isActive        │       │ coordinates     │
│ lastLogin       │       │ createdAt       │       │ isActive        │
│ isActive        │       │ createdBy (FK)  │       │ createdAt       │
└─────────────────┘       └─────────────────┘       └─────────────────┘
         │                                                   │
         │                                                   │
         ▼                                                   ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   DEPLOYMENTS   │       │   CATEGORIES    │       │      ITEMS      │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ deploymentId(PK)│       │ categoryId (PK) │       │ itemId (PK)     │
│ itemId (FK)     │◄──────┤ name            │◄──────┤ categoryId (FK) │
│ userId (FK)     │       │ description     │       │ locationId (FK) │
│ locationId (FK) │       │ icon            │       │ departmentId(FK)│
│ deployedBy (FK) │       │ color           │       │ name            │
│ deploymentDate  │       │ isActive        │       │ description     │
│ expectedReturn  │       │ createdAt       │       │ serialNumber    │
│ actualReturn    │       │ createdBy (FK)  │       │ assetTag        │
│ status          │       └─────────────────┘       │ status          │
│ purpose         │                                 │ purchaseDate    │
│ notes           │                                 │ warrantyExpiry  │
│ condition       │                                 │ value           │
│ createdAt       │                                 │ qrCode          │
│ updatedAt       │                                 │ specifications  │
└─────────────────┘                                 │ createdAt       │
                                                    │ updatedAt       │
                                                    │ createdBy (FK)  │
                                                    └─────────────────┘
                                                             │
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │   MAINTENANCE   │
                                                    ├─────────────────┤
                                                    │ maintenanceId(PK)│
                                                    │ itemId (FK)     │
                                                    │ type            │
                                                    │ description     │
                                                    │ scheduledDate   │
                                                    │ completedDate   │
                                                    │ technician (FK) │
                                                    │ cost            │
                                                    │ status          │
                                                    │ priority        │
                                                    │ notes           │
                                                    │ createdAt       │
                                                    │ createdBy (FK)  │
                                                    └─────────────────┘
```

## Data Flow Relationships

```
User Authentication Flow:
┌─────────┐    login    ┌─────────┐    verify    ┌─────────┐
│  User   │ ────────► │Firebase │ ──────────► │  Users  │
│ (Auth)  │           │  Auth   │             │Collection│
└─────────┘           └─────────┘             └─────────┘

Inventory Management Flow:
┌─────────┐   create   ┌─────────┐   assign   ┌─────────┐
│  Items  │ ────────► │Categories│ ────────► │Locations│
└─────────┘           └─────────┘           └─────────┘
     │                                           │
     │                                           │
     ▼                deploy                     ▼
┌─────────┐ ◄────────────────────────────── ┌─────────┐
│Deployments│                              │  Users  │
└─────────┘                                └─────────┘

Maintenance Tracking Flow:
┌─────────┐   schedule   ┌─────────┐   assign   ┌─────────┐
│  Items  │ ──────────► │Maintenance│ ────────► │Technician│
└─────────┘             └─────────┘            │ (Users) │
                                               └─────────┘
```

## Security Rules Structure

```
Firestore Security Rules:
├── users/
│   ├── read: authenticated users
│   ├── write: admin roles only
│   └── update: own profile only
│
├── items/
│   ├── read: all authenticated users
│   ├── write: admin/manager roles
│   └── update: admin/manager roles
│
├── categories/
│   ├── read: all authenticated users
│   ├── write: admin roles only
│   └── update: admin roles only
│
├── departments/
│   ├── read: all authenticated users
│   ├── write: admin roles only
│   └── update: admin roles only
│
├── locations/
│   ├── read: all authenticated users
│   ├── write: admin/manager roles
│   └── update: admin/manager roles
│
├── deployments/
│   ├── read: all authenticated users
│   ├── write: admin/manager roles
│   └── update: admin/manager roles
│
└── maintenance/
    ├── read: all authenticated users
    ├── write: admin/manager roles
    └── update: admin/manager roles
```

## Key Data Types and Constraints

```
Field Types:
├── string: text data (names, descriptions, IDs)
├── timestamp: date/time values
├── number: numeric values (quantities, prices)
├── boolean: true/false values
├── geopoint: geographical coordinates
├── map: complex nested objects
└── array: lists of values

Status Enumerations:
├── User Roles: SuperAdmin | Admin | Manager | User
├── Item Status: Available | Deployed | Maintenance | Retired
├── Deployment Status: Active | Returned | Overdue | Lost
├── Maintenance Status: Scheduled | InProgress | Completed | Cancelled
├── Priority Levels: Low | Medium | High | Critical
└── Location Types: Laboratory | Office | Storage | Classroom

Primary Keys (Auto-generated):
├── userId (users collection)
├── itemId (items collection)
├── categoryId (categories collection)
├── departmentId (departments collection)
├── locationId (locations collection)
├── deploymentId (deployments collection)
└── maintenanceId (maintenance collection)
```

## Indexing Strategy

```
Firestore Indexes:
├── Composite Indexes:
│   ├── items: (status, departmentId, createdAt)
│   ├── deployments: (status, userId, deploymentDate)
│   ├── deployments: (itemId, status, deploymentDate)
│   ├── maintenance: (status, priority, scheduledDate)
│   └── users: (role, department, isActive)
│
├── Single Field Indexes:
│   ├── items.serialNumber (unique)
│   ├── items.assetTag (unique)
│   ├── users.email (unique)
│   ├── categories.name
│   ├── departments.name
│   └── locations.name
│
└── Array Indexes:
    └── items.specifications (for complex searches)
```
