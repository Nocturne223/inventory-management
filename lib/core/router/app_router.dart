import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_list_page.dart';
import '../../features/inventory/presentation/pages/add_component_page.dart';
import '../../features/inventory/presentation/pages/component_detail_page.dart';
import '../../features/inventory/presentation/pages/edit_item_page.dart';
import '../../features/deployment/presentation/pages/deployment_list_page.dart';
import '../../features/deployment/presentation/pages/create_deployment_page.dart';
import '../../features/deployment/presentation/pages/edit_deployment_page.dart';
import '../../features/deployment/presentation/pages/deployment_detail_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/laboratory/presentation/pages/laboratory_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../core/models/deployment_models.dart';
import '../../core/models/inventory_models.dart';

class AppRouter {
  // Route constants
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String addComponent = '/inventory/add';
  static const String editInventory = '/inventory/edit';
  static const String componentDetail = '/inventory/detail';
  static const String deployments = '/deployments';
  static const String createDeployment = '/deployments/create';
  static const String editDeployment = '/deployments/edit';
  static const String deploymentDetail = '/deployments/detail';
  static const String analytics = '/analytics';
  static const String maintenance = '/maintenance';
  static const String laboratory = '/laboratory';
  static const String login = '/login';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        );

      case inventory:
        return MaterialPageRoute(
          builder: (_) => const InventoryListPage(),
        );

      case addComponent:
        return MaterialPageRoute(
          builder: (_) => const AddComponentPage(),
        );

      case componentDetail:
        final componentId = settings.arguments as String?;
        if (componentId == null) {
          return _errorRoute('Component ID required');
        }
        return MaterialPageRoute(
          builder: (_) => ComponentDetailPage(componentId: componentId),
        );

      case editInventory:
        final item = settings.arguments as InventoryItem?;
        if (item == null) {
          return _errorRoute('Inventory item required');
        }
        return MaterialPageRoute(
          builder: (_) => EditItemPage(item: item),
        );

      case deployments:
        return MaterialPageRoute(
          builder: (_) => const DeploymentListPage(),
        );

      case createDeployment:
        return MaterialPageRoute(
          builder: (_) => const CreateDeploymentPage(),
        );

      case editDeployment:
        final deployment = settings.arguments as Deployment?;
        if (deployment == null) {
          return _errorRoute('Deployment object required');
        }
        return MaterialPageRoute(
          builder: (_) => EditDeploymentPage(deployment: deployment),
        );

      case deploymentDetail:
        final deploymentId = settings.arguments as String?;
        if (deploymentId == null) {
          return _errorRoute('Deployment ID required');
        }
        return MaterialPageRoute(
          builder: (_) => DeploymentDetailPage(deploymentId: deploymentId),
        );

      case analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsPage(),
        );

      case maintenance:
        return MaterialPageRoute(
          builder: (_) => const MaintenancePage(),
        );

      case laboratory:
        return MaterialPageRoute(
          builder: (_) => const LaboratoryPage(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(), // Default to dashboard
        );
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error: $message'),
        ),
      ),
    );
  }
}
