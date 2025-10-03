# 📋 MIT College IT Inventory Management System

A comprehensive Flutter-based inventory management system designed specifically for college IT departments. This application provides robust tracking, deployment analytics, and maintenance management for IT equipment and components.

## 🎯 Project Overview

**Purpose**: Complete inventory management solution for MIT College IT Department
**Context**: Component tracking, deployment analytics, and laboratory management
**Technology**: Flutter frontend with Firebase/Firestore backend

## ✨ Key Features

### 🔧 Core Inventory Management

- **Component Lifecycle Tracking**: Full lifecycle from acquisition to disposal
- **Real-time Status Updates**: Available, Deployed, Maintenance, Damaged, Disposed
- **QR Code Integration**: Generate and scan QR codes for quick component identification
- **Asset Tagging System**: Unique asset tags for institutional tracking

### 🔍 Advanced Search & Filtering

- **Multi-parameter Search**: Search by name, brand, model, serial number, asset tag
- **Category Filtering**: CPU, RAM, Motherboard, Graphics Cards, Storage, etc.
- **Status-based Filtering**: Filter components by current status
- **Location-based Search**: Find components by laboratory or department

### 🏢 Laboratory Management

- **Multi-lab Support**: Manage multiple computer laboratories
- **Occupancy Tracking**: Real-time lab capacity and utilization monitoring
- **Equipment Assignment**: Track component assignments to specific labs
- **Resource Allocation**: Optimize equipment distribution across departments

### 📊 Deployment Analytics

- **Usage Patterns**: Track component deployment history and usage trends
- **Utilization Metrics**: Analyze equipment utilization rates
- **Deployment Workflow**: Streamlined process for equipment deployment
- **Return Management**: Track and manage equipment returns

### 🔧 Maintenance Management

- **Scheduled Maintenance**: Plan and track routine maintenance activities
- **Work Order System**: Create and manage maintenance work orders
- **Maintenance History**: Complete maintenance records for each component
- **Budget Tracking**: Track maintenance costs and budget allocation

### 📈 Reporting & Analytics

- **Component Distribution Charts**: Visual representation of inventory composition
- **Utilization Reports**: Equipment usage and efficiency analytics
- **Financial Reporting**: Cost tracking and budget analysis
- **Trend Analysis**: Historical data analysis and forecasting

### 👥 User Management & Permissions

- **Role-based Access**: Admin, Manager, Technician, User roles
- **Permission System**: Granular permissions for different operations
- **Department Integration**: User organization by academic departments
- **Audit Trail**: Track all user actions and changes

## 💻 Technology Stack

### Frontend (Flutter)

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **UI Components**: Material Design 3
- **State Management**: Riverpod
- **Charts**: FL Chart & Syncfusion Charts
- **QR Code**: QR Flutter & QR Code Scanner

### Backend (Firebase)

- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Analytics**: Firebase Analytics

### Development Tools

- **IDE**: VS Code / Android Studio
- **Version Control**: Git
- **Package Manager**: Pub
- **Build System**: Flutter Build

## 🏗️ Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── config/                     # Configuration files
│   │   └── firebase_config.dart    # Firebase configuration
│   ├── models/                     # Data models
│   │   ├── component.dart          # Component model
│   │   ├── laboratory.dart         # Laboratory & deployment models
│   │   └── user.dart              # User & maintenance models
│   ├── router/                     # Navigation routing
│   │   └── app_router.dart        # App route definitions
│   └── theme/                      # UI theming
│       └── app_theme.dart         # App theme configuration
├── features/                       # Feature modules
│   ├── auth/                      # Authentication
│   │   └── presentation/pages/
│   │       └── login_page.dart
│   ├── dashboard/                 # Main dashboard
│   │   ├── presentation/pages/
│   │   │   └── dashboard_page.dart
│   │   └── widgets/               # Dashboard widgets
│   ├── inventory/                 # Inventory management
│   │   └── presentation/pages/
│   │       ├── inventory_list_page.dart
│   │       ├── add_component_page.dart
│   │       └── component_detail_page.dart
│   ├── analytics/                 # Analytics & reporting
│   ├── deployment/                # Deployment management
│   ├── laboratory/                # Laboratory management
│   ├── maintenance/               # Maintenance management
│   └── profile/                   # User profile
└── providers/                     # State management
    └── auth_provider.dart         # Authentication provider
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.0 or higher)

   ```bash
   flutter --version
   ```

2. **Firebase Account** for backend services

3. **Android Studio** or **VS Code** with Flutter extensions

### Installation Steps

1. **Clone the Repository**

   ```bash
   git clone <repository-url>
   cd inventory-management
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download and place configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
   - Update `lib/core/config/firebase_config.dart` with your project details

4. **Configure Firestore Database**

   - Enable Firestore in your Firebase project
   - Set up security rules for production use
   - Create initial collections: `users`, `components`, `laboratories`, `deployments`, `maintenance`

5. **Run the Application**
   ```bash
   flutter run
   ```

### Initial Setup

1. **Create Admin User**

   - Use Firebase Auth to create your first admin user
   - Manually add user document to Firestore `users` collection with admin role

2. **Seed Sample Data** (Optional)
   - Add sample components and laboratories for testing
   - Import existing inventory data if available

## 🔐 Authentication & Demo Accounts

The application includes demo accounts for testing:

- **Admin**: admin@mit.edu / admin123
- **Manager**: manager@mit.edu / manager123
- **User**: user@mit.edu / user123

## 📱 Key Screens & Functionality

### 🏠 Dashboard

- Welcome message with user information
- Key metrics: Total Components, Deployed, Available, Maintenance
- Quick actions: Add Component, Scan QR, View Reports, Settings
- Recent activities feed
- Component distribution charts

### 📦 Inventory Management

- **List View**: Searchable and filterable component list
- **Detail View**: Complete component information with QR code
- **Add/Edit**: Comprehensive form for component data entry
- **Categories**: CPU, RAM, Motherboard, Graphics Card, Storage, Power Supply, Case, Peripherals

### 🏢 Laboratory Management

- Laboratory listing with occupancy rates
- Equipment assignment tracking
- Capacity management
- Department organization

### 📊 Analytics & Reporting

- Component distribution analytics
- Utilization rate tracking
- Maintenance cost analysis
- Trend reporting

## 👥 Team Members

**Pamantasan ng Lungsod ng Muntinlupa**

- Ronald E. Amparo
- Rommel Palermo
- Albert James Mangcao
- Mark Dave Fetalino

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues & Support

For bug reports and feature requests, please create an issue in the repository.

## 🔄 Future Enhancements

- [ ] Offline functionality with data synchronization
- [ ] Advanced reporting with PDF export
- [ ] Barcode scanning integration
- [ ] Mobile device management features
- [ ] Integration with institutional systems
- [ ] Advanced analytics with ML predictions
- [ ] Multi-language support
- [ ] API for third-party integrations

---

**MIT College IT Inventory Management System** - Streamlining IT asset management for educational institutions.
