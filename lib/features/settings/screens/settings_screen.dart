import 'package:flutter/material.dart';

import '../../../core/utils/theme.dart';

/// Settings Screen
/// App-wide settings and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
          ),
          Card(
            child: AbsorbPointer(
              absorbing: !_notificationsEnabled,
              child: Opacity(
                opacity: _notificationsEnabled ? 1.0 : 0.5,
                child: SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound for notifications'),
                  value: _soundEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _soundEnabled = value);
                        }
                      : null,
                ),
              ),
            ),
          ),
          Card(
            child: AbsorbPointer(
              absorbing: !_notificationsEnabled,
              child: Opacity(
                opacity: _notificationsEnabled ? 1.0 : 0.5,
                child: SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: _vibrationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _vibrationsEnabled = value);
                        }
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Settings
          Text(
            'App',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                // TODO: Implement theme switching
              },
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('App Version'),
              subtitle: Text('Version 1.0.0'),
              trailing: Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data & Privacy
          Text(
            'Data & Privacy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('View our privacy policy'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Terms of Service'),
              subtitle: const Text('View our terms'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
