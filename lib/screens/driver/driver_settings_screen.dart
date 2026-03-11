// screens/driver/driver_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', value);
      setState(() => _notificationsEnabled = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToUpdateNotifications),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00B25E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  Text(
                    AppLocalizations.of(context)!.appearance,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingCard(
                    icon: Icons.brightness_6,
                    title: AppLocalizations.of(context)!.theme,
                    subtitle: themeProvider.themeMode == ThemeMode.dark
                        ? AppLocalizations.of(context)!.darkMode
                        : AppLocalizations.of(context)!.lightMode,
                    trailing: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: const Color(0xFF00B25E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Language Section
                  Text(
                    AppLocalizations.of(context)!.language,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingCard(
                    icon: Icons.language,
                    title: AppLocalizations.of(context)!.appLanguage,
                    subtitle: Provider.of<LocaleProvider>(context).currentLanguageName,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLanguageDialog(),
                  ),
                  const SizedBox(height: 24),

                  // Notifications Section
                  Text(
                    AppLocalizations.of(context)!.notifications,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingCard(
                    icon: Icons.notifications,
                    title: AppLocalizations.of(context)!.pushNotifications,
                    subtitle:
                        _notificationsEnabled ? AppLocalizations.of(context)!.enabled : AppLocalizations.of(context)!.disabled,
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeColor: const Color(0xFF00B25E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  Text(
                    AppLocalizations.of(context)!.aboutSection,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingCard(
                    icon: Icons.info_outline,
                    title: AppLocalizations.of(context)!.appVersion,
                    subtitle: '1.0.0',
                    trailing: const SizedBox(),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    icon: Icons.privacy_tip_outlined,
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    subtitle: AppLocalizations.of(context)!.viewPrivacyPolicy,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to privacy policy
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    icon: Icons.description_outlined,
                    title: AppLocalizations.of(context)!.termsOfService,
                    subtitle: AppLocalizations.of(context)!.viewTerms,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to terms of service
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00B25E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00B25E),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languages = LocaleProvider.supportedLanguages;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.key),
              value: entry.key,
              groupValue: localeProvider.currentLanguageName,
              activeColor: const Color(0xFF00B25E),
              onChanged: (value) {
                if (value != null) {
                  localeProvider.setLocale(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.languageChanged(value)),
                      backgroundColor: const Color(0xFF00B25E),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
