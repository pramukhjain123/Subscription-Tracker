import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';
import '../services/notification_service.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String currency = 'INR';

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    return CustomScrollView(
      key: const PageStorageKey('settings'),
      slivers: [
        const SliverAppBar(title: Text('Settings'), floating: true),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverList.list(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Selector<AuthProvider, String?>(
                        selector: (_, p) => p.currentUser,
                        builder: (context, user, _) => Row(
                          children: [
                            const Icon(Icons.person_outline),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user ?? 'Not logged in')),
                            TextButton(
                              onPressed: () => _showChangePasswordDialog(context),
                              child: const Text('Change Password'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('Auto-sync usage'),
                  subtitle: const Text('Every 5 minutes while the app is open'),
                  value: context.watch<SubscriptionProvider>().isAutoSyncEnabled,
                  onChanged: (v) async {
                    final sp = context.read<SubscriptionProvider>();
                    if (v) {
                      sp.startAutoSync();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Auto-sync started (every 5 minutes)')),
                      );
                    } else {
                      sp.stopAutoSync();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Auto-sync stopped')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                        ],
                        selected: {themeCtrl.mode},
                        onSelectionChanged: (s) => themeCtrl.setMode(s.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Due dates and usage reminders'),
                  value: notificationsEnabled,
                  onChanged: (v) async {
                    setState(() => notificationsEnabled = v);
                    if (v) {
                      await NotificationService.initialize();
                    } else {
                      await NotificationService.cancelAllNotifications();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notification_important_outlined),
                  title: const Text('Send sample contextual notifications'),
                  subtitle: const Text('Quickly verify notification channels and permissions'),
                  onTap: () async {
                    await NotificationService.sendSampleContextual();
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sync_outlined),
                  title: const Text('Sync usage from device'),
                  subtitle: const Text('Reads Digital Wellbeing usage to update hours'),
                  onTap: () async {
                    await context.read<SubscriptionProvider>().syncUsageFromDevice(days: 30);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usage sync requested')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(currency),
                  trailing: DropdownButton<String>(
                    value: currency,
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR ₹')),
                      DropdownMenuItem(value: 'USD', child: Text('USD \$')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR €')),
                    ],
                    onChanged: (v) => setState(() => currency = v ?? currency),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.red.withOpacity(0.08),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match')),
                );
                return;
              }
              final ok = await context.read<AuthProvider>().changePassword(currentCtrl.text, newCtrl.text);
              if (!mounted) return;
              Navigator.pop(ctx);
              final msg = ok ? 'Password changed' : (context.read<AuthProvider>().error ?? 'Password change failed');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
