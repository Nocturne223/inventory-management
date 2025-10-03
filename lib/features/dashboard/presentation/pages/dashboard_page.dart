import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user.dart';
// import '../../../inventory/presentation/pages/inventory_list_page.dart';
// import '../../../analytics/presentation/pages/analytics_page.dart';
// import '../../../deployment/presentation/pages/deployment_page.dart';
// import '../../../laboratory/presentation/pages/laboratory_page.dart';
// import '../../../maintenance/presentation/pages/maintenance_page.dart';
// import '../../../profile/presentation/pages/profile_page.dart';
import '../../../admin/presentation/pages/data_management_page.dart';
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
    const _PlaceholderPage(title: 'Inventory'),
    const _PlaceholderPage(title: 'Deployment'),
    const _PlaceholderPage(title: 'Laboratory'),
    const _PlaceholderPage(title: 'Maintenance'),
    const _PlaceholderPage(title: 'Analytics'),
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
    const BottomNavigationBarItem(
      icon: Icon(Icons.build),
      label: 'Maintenance',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MIT IT Inventory',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Developer menu (only in debug mode)
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'data_management') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataManagementPage(),
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
              ],
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const _PlaceholderPage(title: 'Profile'),
                ),
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
                Navigator.pushNamed(context, '/add-component');
              },
              child: const Icon(Icons.add),
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

          // Stats cards
          const Row(
            children: [
              Expanded(
                child: DashboardStatsCard(
                  title: 'Total Components',
                  value: '1,245',
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  trend: '+12%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardStatsCard(
                  title: 'Deployed',
                  value: '892',
                  icon: Icons.send,
                  color: Colors.green,
                  trend: '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: DashboardStatsCard(
                  title: 'Available',
                  value: '298',
                  icon: Icons.check_circle,
                  color: Colors.orange,
                  trend: '-3%',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardStatsCard(
                  title: 'Maintenance',
                  value: '55',
                  icon: Icons.build,
                  color: Colors.red,
                  trend: '+8%',
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
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 30,
                    title: 'CPU',
                    color: ComponentColors.getCategoryColor('CPU'),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: 'RAM',
                    color: ComponentColors.getCategoryColor('RAM'),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: 'Storage',
                    color: ComponentColors.getCategoryColor('Storage'),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: 'GPU',
                    color: ComponentColors.getCategoryColor('Graphics Card'),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: 'Other',
                    color: ComponentColors.getCategoryColor('Other'),
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
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
