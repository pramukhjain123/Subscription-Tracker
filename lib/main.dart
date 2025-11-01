import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_subscription_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'ui/app_shell.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('App: Initializing...');
    await NotificationService.initialize();
    runApp(const MyApp());
  } catch (e) {
    print('App: Error during initialization: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) {
          return MaterialApp(
            title: 'Subscription Tracker',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeCtrl.mode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return const SplashScreen();
                }
                if (authProvider.isAuthenticated) {
                  return const AppShell();
                } else {
                  return const LoginScreen();
                }
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/add': (context) => const AddSubscriptionScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}