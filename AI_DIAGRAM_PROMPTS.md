# AI Image Generation Prompts for AssetFlow System Analysis Diagrams

## 1. Use Case Diagrams

### Prompt 1: Main Use Case Diagram

```
Create a professional UML use case diagram for AssetFlow Inventory Management System. Include:

ACTORS (stick figures on left and right sides):
- SuperAdmin (left side)
- Admin (left side)
- Manager (left side)
- User (left side)
- System (right side)

USE CASES (ovals in center):
- Login/Authenticate
- Manage User Accounts
- Add/Edit/Delete Items
- Categorize Equipment
- Deploy Equipment
- Return Equipment
- Track Deployments
- Generate QR Codes
- View Analytics Dashboard
- Schedule Maintenance
- Manage Locations
- Export Reports
- Monitor Laboratory Occupancy

RELATIONSHIPS:
- Draw connecting lines from actors to their accessible use cases
- Include <<extends>> and <<includes>> relationships where appropriate
- SuperAdmin can access all use cases
- Admin can access most use cases except user management
- Manager can access deployment and tracking use cases
- User can access basic viewing and personal deployment use cases

Style: Clean, professional UML notation with proper symbols, black and white, technical diagram style
```

### Prompt 2: Authentication Use Case Diagram

```
Create a detailed UML use case diagram focusing on Authentication subsystem for AssetFlow:

ACTORS:
- Anonymous User
- Authenticated User
- Firebase Auth System

USE CASES:
- Login with Email/Password
- Logout
- Reset Password
- Register New User (Admin only)
- Verify Email
- Update Profile
- Change Password
- Assign User Roles
- Deactivate Account

RELATIONSHIPS:
- Show inheritance between Anonymous and Authenticated User
- Include <<includes>> relationship for email verification during registration
- Show <<extends>> for forgot password extending login
- Connect Firebase Auth System to verification processes

Style: Professional UML diagram, clean lines, proper use case notation
```

## 2. Data Flow Diagrams (DFD)

### Prompt 1: Context Diagram (Level 0 DFD)

```
Create a Context Diagram (Level 0 Data Flow Diagram) for AssetFlow Inventory Management System:

CENTER:
- Large circle labeled "AssetFlow Inventory Management System"

EXTERNAL ENTITIES (rectangles around the circle):
- Users (Admins, Managers, Users)
- Firebase Authentication
- Firebase Database
- QR Code Scanner
- Report Recipients
- Equipment Suppliers

DATA FLOWS (labeled arrows):
- FROM Users: Login Credentials, Item Data, Deployment Requests
- TO Users: Dashboard Data, Reports, QR Codes, Notifications
- FROM Firebase Auth: Authentication Status, User Roles
- TO Firebase Auth: Login Requests, User Data
- FROM Firebase DB: Item Records, Deployment History
- TO Firebase DB: Updated Records, New Items
- FROM QR Scanner: Scanned Codes
- TO QR Scanner: Generated QR Codes

Style: Professional DFD notation, circles for processes, rectangles for external entities, labeled arrows for data flows, black and white technical diagram
```

### Prompt 2: Level 1 DFD - Main System Processes

```
Create a Level 1 Data Flow Diagram for AssetFlow showing main system processes:

PROCESSES (numbered circles):
1. Authentication Management
2. Inventory Management
3. Deployment Processing
4. Analytics & Reporting
5. Laboratory Management
6. Maintenance Tracking

DATA STORES (open rectangles):
- D1: Users Database
- D2: Items Database
- D3: Deployments Database
- D4: Categories Database
- D5: Locations Database
- D6: Maintenance Database

EXTERNAL ENTITIES:
- Users
- Administrators
- System Notifications

DATA FLOWS:
- Show data movement between processes and data stores
- Label all arrows with specific data descriptions
- Include feedback loops where appropriate

Style: Standard DFD notation, numbered circles for processes, open rectangles for data stores, proper flow labeling
```

### Prompt 3: Level 2 DFD - Deployment Process Detail

```
Create a detailed Level 2 Data Flow Diagram focusing on the Deployment Process:

PROCESSES (numbered circles 3.1, 3.2, etc.):
3.1 Validate Deployment Request
3.2 Check Item Availability
3.3 Assign Equipment
3.4 Generate Deployment Record
3.5 Update Item Status
3.6 Send Notifications

DATA STORES:
- D2: Items Database
- D3: Deployments Database
- D1: Users Database
- D5: Locations Database

EXTERNAL ENTITIES:
- Requesting User
- Approving Manager
- Email System

DATA FLOWS:
- Show detailed data movement through the deployment process
- Include decision points and validation steps
- Label all data flows with specific content

Style: Technical DFD notation with clear process flow, proper numbering scheme
```

## 3. Entity-Relationship Diagrams (ERD)

### Prompt 1: Conceptual ERD

```
Create a Conceptual Entity-Relationship Diagram (ERD) for AssetFlow Inventory System:

ENTITIES (rectangles):
- USER
- ITEM
- CATEGORY
- DEPARTMENT
- LOCATION
- DEPLOYMENT
- MAINTENANCE

RELATIONSHIPS (diamonds):
- USER "manages" DEPARTMENT
- USER "creates" ITEM
- ITEM "belongs to" CATEGORY
- ITEM "located in" LOCATION
- LOCATION "part of" DEPARTMENT
- USER "deploys" ITEM (creates DEPLOYMENT)
- ITEM "requires" MAINTENANCE
- USER "performs" MAINTENANCE

CARDINALITIES:
- Show 1:1, 1:M, M:N relationships with proper notation
- Include cardinality symbols (1, M, crow's feet)
- Add relationship descriptors

Style: Professional ERD notation, rectangles for entities, diamonds for relationships, clear cardinality markings, black and white technical diagram
```

### Prompt 2: Logical ERD with Attributes

```
Create a detailed Logical ERD for AssetFlow showing entities with key attributes:

ENTITIES with PRIMARY KEYS (PK) and attributes:

USER:
- userId (PK)
- email
- displayName
- role
- department
- isActive

ITEM:
- itemId (PK)
- name
- serialNumber
- assetTag
- categoryId (FK)
- locationId (FK)
- status
- value

DEPLOYMENT:
- deploymentId (PK)
- itemId (FK)
- userId (FK)
- deploymentDate
- expectedReturn
- status

CATEGORY:
- categoryId (PK)
- name
- description

LOCATION:
- locationId (PK)
- name
- type
- capacity

RELATIONSHIPS:
- Show all foreign key relationships with proper notation
- Include identifying vs non-identifying relationships
- Mark primary keys with (PK) and foreign keys with (FK)

Style: Detailed ERD with attribute lists, proper key notation, relationship lines with cardinality
```

### Prompt 3: Physical ERD (Database Schema)

```
Create a Physical ERD showing the actual database implementation for AssetFlow:

TABLES (rectangles with table names and column details):

users:
├── uid: string (PK)
├── email: string (UNIQUE)
├── displayName: string
├── role: enum
├── department: string
├── createdAt: timestamp
├── isActive: boolean

items:
├── itemId: string (PK)
├── name: string
├── serialNumber: string (UNIQUE)
├── assetTag: string (UNIQUE)
├── categoryId: string (FK → categories)
├── locationId: string (FK → locations)
├── status: enum
├── purchaseDate: timestamp
├── value: decimal

deployments:
├── deploymentId: string (PK)
├── itemId: string (FK → items)
├── userId: string (FK → users)
├── deploymentDate: timestamp
├── expectedReturn: timestamp
├── status: enum

FOREIGN KEY RELATIONSHIPS:
- Draw connection lines between related tables
- Show referential integrity constraints
- Include index indicators where appropriate

Style: Database schema diagram style, table boxes with column details, data types shown, foreign key relationships clearly marked
```

## 4. System Architecture Diagram

### Prompt 1: High-Level Architecture

```
Create a system architecture diagram for AssetFlow showing the 3-tier architecture:

PRESENTATION TIER (top):
- Flutter Web Application
- Material Design 3 UI
- Responsive Web Interface
- User Authentication UI

APPLICATION TIER (middle):
- Riverpod State Management
- Business Logic Layer
- API Integration Layer
- Real-time Synchronization

DATA TIER (bottom):
- Firebase Authentication
- Cloud Firestore Database
- Firebase Hosting
- Firebase Cloud Functions

CONNECTIONS:
- Show data flow arrows between tiers
- Include Firebase SDK connections
- Show real-time data streams
- Include security boundaries

EXTERNAL SYSTEMS:
- QR Code Generation
- Email Notifications
- Analytics Services

Style: Clean architectural diagram with layered boxes, clear separation of concerns, proper technical notation, modern cloud architecture style
```

### Prompt 2: Component Architecture Diagram

```
Create a detailed component architecture diagram for AssetFlow Flutter application:

MAIN COMPONENTS (interconnected boxes):

Core Layer:
- Router/Navigation
- Dependency Injection
- Theme Management
- Error Handling

Feature Modules:
- Authentication Module
- Inventory Module
- Deployment Module
- Analytics Module
- Laboratory Module
- User Management Module

Shared Components:
- Common Widgets
- Utility Functions
- Models/DTOs
- Constants

External Dependencies:
- Firebase SDK
- Material Design 3
- QR Code Generator
- Chart Libraries

CONNECTIONS:
- Show dependency arrows between components
- Indicate data flow directions
- Mark interface boundaries
- Show shared component usage

Style: Technical component diagram, modular boxes with clear hierarchies, dependency arrows, clean software architecture visualization
```

## General Instructions for All Prompts:

**Style Guidelines:**

- Use professional, technical diagram notation
- Black and white or minimal color scheme
- High contrast for clarity
- Clean, readable fonts
- Proper spacing and alignment
- Standard UML/technical diagramming symbols

**Quality Requirements:**

- High resolution (at least 1920x1080)
- Scalable vector style preferred
- Professional presentation quality
- Clear labeling and legends
- Consistent symbol usage
- Technical accuracy

**Additional Notes:**

- Ensure all text is readable and properly sized
- Use standard industry symbols and notation
- Maintain consistency across all diagrams
- Include legends where appropriate
- Focus on clarity and technical accuracy over artistic style

```

```
