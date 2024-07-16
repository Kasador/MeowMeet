import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../generated/l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(localizations.common),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: Text(localizations.language),
                value: const Text('English'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: const Icon(Icons.format_paint),
                title: Text(localizations.enableCustomTheme),
              ),
            ],
          ),
          SettingsSection(
            title: Text(localizations.account),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.phone),
                title: Text(localizations.phoneNumber),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.email),
                title: Text(localizations.email),
              ),
            ],
          ),
          SettingsSection(
            title: Text(localizations.security),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.lock),
                title: Text(localizations.changePassword),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: const Icon(Icons.fingerprint),
                title: Text(localizations.useFingerprint),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: const Icon(Icons.lock),
                title: Text(localizations.enableLock),
              ),
            ],
          ),
          SettingsSection(
            title: Text(localizations.misc),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.description),
                title: Text(localizations.termsOfService),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.collections_bookmark),
                title: Text(localizations.openSourceLicenses),
              ),
            ],
          ),
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text(
                  localizations.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                onPressed: (context) {
                  _logout(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Update the route to your login screen
  }
}
