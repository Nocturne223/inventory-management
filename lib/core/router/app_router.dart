import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

class AppRouter {
  static const String dashboard = '/dashboard';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(), // Default to dashboard
        );
    }
  }
}