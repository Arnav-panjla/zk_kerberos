import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logOut(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'userId');

    final settings = Provider.of<SettingsModel>(context, listen: false);
    await settings.setBiometricEnabled(false);

    if (context.mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Theme', theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (ThemeMode? value) {
                      if (value != null) settings.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (ThemeMode? value) {
                      if (value != null) settings.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (ThemeMode? value) {
                      if (value != null) settings.setThemeMode(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Security', theme),
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: const Text(
                'Enable Biometric Login',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              value: settings.isBiometricEnabled,
              onChanged: (bool value) {
                settings.setBiometricEnabled(value);
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('General', theme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: true,
                  onChanged: (bool value) {},
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Log Out & Clear User ID',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            onTap: () => _logOut(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.primary
              : theme.colorScheme.onBackground.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}