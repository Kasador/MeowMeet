import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import '../generated/l10n.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
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
                onPressed: (context) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ));
                },
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
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  _LanguageSettingsScreenState createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _currentLanguage;
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, String>> _filteredLanguages = [];
  Map<String, String> languageMap = {};

  @override
  void initState() {
    super.initState();
    _currentLanguage = 'en'; // Set a default value for _currentLanguage
    _loadCurrentLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvailableLanguages();
  }

  void _loadCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language_code') ?? 'en';
    });
  }

  void _loadAvailableLanguages() {
    final localeNames = LocaleNames.of(context);
    if (localeNames != null) {
      setState(() {
        languageMap = {
          'en': localeNames.nameOf('en') ?? 'English',
          'es': localeNames.nameOf('es') ?? 'Spanish',
          'fr': localeNames.nameOf('fr') ?? 'French',
          'de': localeNames.nameOf('de') ?? 'German',
          'zh': localeNames.nameOf('zh') ?? 'Simplified Chinese',
          'zh_Hant': localeNames.nameOf('zh_Hant') ?? 'Traditional Chinese'
        };
        _filteredLanguages = languageMap.entries.toList();
      });
    } else {
      print('LocaleNames.of(context) is null');
    }
  }

  void _filterLanguages(String query) {
    setState(() {
      _filteredLanguages = languageMap.entries
          .where((entry) => entry.value.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _changeLanguage(String? languageCode) async {
    if (languageCode == null || languageCode == _currentLanguage) return;

    showDialog(
      context: context,
      builder: (context) {
        final localizations = S.of(context);
        return AlertDialog(
          title: Text(localizations.changeLanguage),
          content: Text(localizations.areYouSureChangeLanguage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_code', languageCode);
                if (!context.mounted) return;
                MainApp.setLocale(context, Locale(languageCode));
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the LanguageSettingsScreen
                Navigator.of(context).pop(); // Close the SettingsScreen and go back to ProfileScreen
              },
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(localizations.language),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: localizations.searchLanguage,
              ),
              onChanged: _filterLanguages,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                return ListTile(
                  title: Text(language.value),
                  trailing: _currentLanguage == language.key ? const Icon(Icons.check) : null,
                  onTap: () => _changeLanguage(language.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
