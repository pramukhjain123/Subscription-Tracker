import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../providers/subscription_provider.dart';
import '../services/usage_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Info Card
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      authProvider.currentUser?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(authProvider.currentUser ?? 'User'),
                  subtitle: const Text('Subscription Tracker User'),
                ),
              ),
              
              const SizedBox(height: 24),

              // Notifications
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: Colors.green),
                  title: const Text('Send Test Notification'),
                  subtitle: const Text('Sends a test in ~3 seconds'),
                  onTap: () async {
                    await NotificationService.sendTestNotification();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification scheduled')),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Usage access
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.indigo),
                  title: const Text('Enable Usage Access'),
                  subtitle: const Text('Required to read Digital Wellbeing usage'),
                  onTap: () async {
                    final ok = await UsageService.openUsageAccessSettings();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Opened settings' : 'Unable to open settings')),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Manual sync usage
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sync, color: Colors.teal),
                  title: const Text('Sync usage from Digital Wellbeing'),
                  subtitle: const Text('Updates usage hours for mapped apps'),
                  onTap: () async {
                    await context.read<SubscriptionProvider>().syncUsageFromDevice(days: 30);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usage sync requested')),
                    );
                  },
                ),
              ),
              
              // Logout Option
              Card(
                color: Colors.red.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Info
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.description_outlined),
                      title: Text('Subscription Tracker'),
                      subtitle: Text('Manage your subscriptions efficiently'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 