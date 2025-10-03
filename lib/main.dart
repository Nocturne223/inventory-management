import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'providers/auth_service.dart';
import 'core/models/app_user.dart';
import 'core/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    setupLocator(useMocks: false);
  } catch (e) {
    setupLocator(useMocks: true);
  }

  runApp(const ProviderScope(child: InventoryApp()));
}

class InventoryApp extends ConsumerWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'AssetFlow Inventory & Deployment System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: authState.when(
        data: (state) {
          if (state is AuthAuthenticated) {
            return const DashboardPage();
          } else {
            return const LoginPage();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => const LoginPage(),
      ),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
