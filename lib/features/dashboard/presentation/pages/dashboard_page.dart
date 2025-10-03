import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firestore_data_service.dart';
import '../../../../features/inventory/providers/inventory_providers.dart'
    as inventory_providers;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user.dart';
import '../../../inventory/presentation/pages/inventory_list_page_new.dart'
    as new_inventory;
import '../../../inventory/presentation/pages/add_item_page.dart';
import '../../../deployment/presentation/pages/deployment_list_page.dart';
// import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../laboratory/presentation/pages/laboratory_page.dart';
// import '../../../maintenance/presentation/pages/maintenance_page.dart';
// import '../../../profile/presentation/pages/profile_page.dart';
import '../../../admin/presentation/pages/data_management_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/recent_activities_widget.dart';
import '../widgets/quick_actions_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const new_inventory.InventoryListPage(
        showAppBar: false), // Use the new inventory page without AppBar
    const DeploymentListPage(),
    const LaboratoryPage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2),
      label: 'Inventory',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.send),
      label: 'Deployment',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.science),
      label: 'Laboratory',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AssetFlow Inventory & Deployment',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // SuperAdmin menu (only for SuperAdmin users)
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);
              if (currentUser?.role != UserRole.superAdmin) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Admin Tools',
                onSelected: (value) {
                  if (value == 'data_management') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataManagementPage(),
                      ),
                    );
                  } else if (value == 'user_management') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'data_management',
                    child: Row(
                      children: [
                        Icon(Icons.storage),
                        SizedBox(width: 8),
                        Text('Data Management'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'user_management',
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text('User Management'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Profile Menu
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);

              return PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        currentUser != null
                            ? '${currentUser.firstName[0]}${currentUser.lastName[0]}'
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
                tooltip: 'User Profile',
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const _PlaceholderPage(title: 'Profile'),
                      ),
                    );
                  } else if (value == 'logout') {
                    // Show logout confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      // Perform logout
                      try {
                        final authService = ref.read(authServiceProvider);
                        await authService.signOut();

                        // Clear user state
                        ref.read(currentUserProvider.notifier).state = null;

                        // Show success message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Logged out successfully'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate to login page explicitly
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child:
                                        Text('Logout failed: ${e.toString()}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  // User info header
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                currentUser != null
                                    ? '${currentUser.firstName[0]}${currentUser.lastName[0]}'
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser?.displayName ?? 'Unknown User',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    currentUser?.email ??
                                        'no-email@example.com',
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentUser?.role ==
                                              UserRole.superAdmin
                                          ? Colors.purple.withValues(alpha: 0.1)
                                          : Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: currentUser?.role ==
                                                UserRole.superAdmin
                                            ? Colors.purple
                                                .withValues(alpha: 0.3)
                                            : Colors.blue
                                                .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      currentUser?.role.displayName ??
                                          'Unknown Role',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: currentUser?.role ==
                                                UserRole.superAdmin
                                            ? Colors.purple[700]
                                            : Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                      ],
                    ),
                  ),
                  // Profile option
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 12),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  // Logout option
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 10,
      ),
      floatingActionButton: _selectedIndex == 1 // Only show on Inventory page
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'Add New Item',
            )
          : null,
    );
  }
}

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(mockCurrentUserProvider);
    final inventoryStats = ref.watch(inventoryStatsProvider);
    final deploymentStats = ref.watch(deploymentStatsProvider);
    final categoryDistribution =
        ref.watch(inventory_providers.categoryDistributionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${currentUser?.firstName ?? 'User'}!',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Department: ${currentUser?.department ?? 'N/A'}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Role: ${currentUser?.role.displayName ?? 'N/A'}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats cards - now using real Firestore data
          Row(
            children: [
              Expanded(
                child: inventoryStats.when(
                  data: (stats) => DashboardStatsCard(
                    title: 'Total Items',
                    value: '${stats['total'] ?? 0}',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  loading: () => const DashboardStatsCard(
                    title: 'Total Items',
                    value: '...',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  error: (_, __) => const DashboardStatsCard(
                    title: 'Total Items',
                    value: 'Error',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: deploymentStats.when(
                  data: (stats) => DashboardStatsCard(
                    title: 'Active Deployments',
                    value: '${stats['active'] ?? 0}',
                    icon: Icons.send,
                    color: Colors.green,
                  ),
                  loading: () => const DashboardStatsCard(
                    title: 'Active Deployments',
                    value: '...',
                    icon: Icons.send,
                    color: Colors.green,
                  ),
                  error: (_, __) => const DashboardStatsCard(
                    title: 'Active Deployments',
                    value: 'Error',
                    icon: Icons.send,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: inventoryStats.when(
                  data: (stats) => DashboardStatsCard(
                    title: 'Available',
                    value: '${stats['available'] ?? 0}',
                    icon: Icons.check_circle,
                    color: Colors.orange,
                  ),
                  loading: () => const DashboardStatsCard(
                    title: 'Available',
                    value: '...',
                    icon: Icons.check_circle,
                    color: Colors.orange,
                  ),
                  error: (_, __) => const DashboardStatsCard(
                    title: 'Available',
                    value: 'Error',
                    icon: Icons.check_circle,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: deploymentStats.when(
                  data: (stats) => DashboardStatsCard(
                    title: 'Overdue Returns',
                    value: '${stats['overdue'] ?? 0}',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                  loading: () => const DashboardStatsCard(
                    title: 'Overdue Returns',
                    value: '...',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                  error: (_, __) => const DashboardStatsCard(
                    title: 'Overdue Returns',
                    value: 'Error',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const QuickActionsWidget(),
          const SizedBox(height: 24),

          // Recent Activities
          Text(
            'Recent Activities',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const RecentActivitiesWidget(),
          const SizedBox(height: 24),

          // Component Categories Chart
          Text(
            'Component Distribution',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: categoryDistribution.when(
              data: (distribution) {
                if (distribution.isEmpty) {
                  return const Center(
                    child: Text(
                      'No inventory data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final sections = distribution.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: entry.key,
                    color: ComponentColors.getCategoryColor(entry.key),
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();

                return PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => const Center(
                child: Text(
                  'Error loading category data',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder page for testing
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
