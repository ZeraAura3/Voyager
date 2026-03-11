// screens/driver/driver_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _driverData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _driverData = doc.data() as Map<String, dynamic>?;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B25E), Color(0xFF66D395)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      (_driverData?['fullName']
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'D'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B25E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _driverData?['fullName'] ?? AppLocalizations.of(context)!.driver,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _driverData?['email'] ?? user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_taxi,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.driver,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.star,
                        value: (_driverData?['rating'] ?? 5.0).toString(),
                        label: AppLocalizations.of(context)!.rating,
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _buildStatItem(
                        icon: Icons.directions_car,
                        value: (_driverData?['totalRides'] ?? 0).toString(),
                        label: AppLocalizations.of(context)!.totalRides,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                AppLocalizations.of(context)!.vehicleInformation,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B25E), Color(0xFF66D395)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B25E).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.yourVehicle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _driverData?['vehicleModel'] ?? AppLocalizations.of(context)!.notSet,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildVehicleDetailRow(
                          Icons.confirmation_number,
                          AppLocalizations.of(context)!.vehicleNumber,
                          _driverData?['vehicleNumber'] ?? AppLocalizations.of(context)!.notSet,
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        _buildVehicleDetailRow(
                          Icons.credit_card,
                          AppLocalizations.of(context)!.licenseNumber,
                          _driverData?['licenseNumber'] ?? AppLocalizations.of(context)!.notSet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Section
            _buildSection(
              context,
              AppLocalizations.of(context)!.settings,
              [
                _buildSettingTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: AppLocalizations.of(context)!.darkMode,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.setThemeMode(value),
                    activeColor: const Color(0xFF00B25E),
                  ),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.language_outlined,
                  title: AppLocalizations.of(context)!.language,
                  subtitle: Provider.of<LocaleProvider>(context).currentLanguageName,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: AppLocalizations.of(context)!.notifications,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.notificationSettingsUpdated),
                          backgroundColor: const Color(0xFF00B25E),
                        ),
                      );
                    },
                    activeColor: const Color(0xFF00B25E),
                  ),
                ),
              ],
            ),

            // Account Section
            _buildSection(
              context,
              AppLocalizations.of(context)!.account,
              [
                _buildSettingTile(
                  context,
                  icon: Icons.person_outline,
                  title: AppLocalizations.of(context)!.editProfile,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.lock_outline,
                  title: AppLocalizations.of(context)!.changePassword,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.phone_outlined,
                  title: AppLocalizations.of(context)!.contactInformation,
                  subtitle: _driverData?['phone'] ?? AppLocalizations.of(context)!.notSet,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditContactDialog(context),
                ),
              ],
            ),

            // Routes Section
            _buildSection(
              context,
              AppLocalizations.of(context)!.usualRoutes,
              [
                _buildSettingTile(
                  context,
                  icon: Icons.route_outlined,
                  title: AppLocalizations.of(context)!.manageRoutes,
                  subtitle: AppLocalizations.of(context)!.addOrEditRoutes,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showManageRoutesDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00B25E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00B25E),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languages = LocaleProvider.supportedLanguages;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final name = languages.keys.elementAt(index);
              final locale = languages.values.elementAt(index);
              return ListTile(
                title: Text(name),
                trailing: localeProvider.locale.languageCode == locale.languageCode
                    ? const Icon(Icons.check, color: Color(0xFF00B25E))
                    : null,
                onTap: () {
                  localeProvider.setLocale(name);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.languageChanged(name)),
                      backgroundColor: const Color(0xFF00B25E),
                    ),
                  );
                },
              );
            },
          ),
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

  void _showEditProfileDialog(BuildContext context) {
    final nameController =
        TextEditingController(text: _driverData?['fullName'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editProfile),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterYourName,
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(user!.uid)
                    .update({'fullName': nameController.text.trim()});

                await _loadDriverData();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
                      backgroundColor: const Color(0xFF00B25E),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B25E),
            ),
            child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(BuildContext context) {
    final phoneController =
        TextEditingController(text: _driverData?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editContact),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(user!.uid)
                    .update({'phone': phoneController.text.trim()});

                await _loadDriverData();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.contactUpdatedSuccess),
                      backgroundColor: const Color(0xFF00B25E),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B25E),
            ),
            child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changePassword),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.confirmNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.passwordMinLength),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                final credential = EmailAuthProvider.credential(
                  email: user?.email ?? '',
                  password: currentPasswordController.text,
                );
                await user?.reauthenticateWithCredential(credential);
                await user?.updatePassword(newPasswordController.text);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.passwordChangedSuccess),
                      backgroundColor: const Color(0xFF00B25E),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B25E),
            ),
            child: Text(AppLocalizations.of(context)!.changePassword,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManageRoutesDialog(BuildContext context) {
    final List<Map<String, dynamic>> currentRoutes =
        _driverData?['usualRoutes'] != null
            ? List<Map<String, dynamic>>.from(_driverData!['usualRoutes'])
            : [];

    showDialog(
      context: context,
      builder: (context) => _ManageRoutesDialog(
        initialRoutes: currentRoutes,
        onSave: (routes) async {
          try {
            User? user = FirebaseAuth.instance.currentUser;
            await FirebaseFirestore.instance
                .collection('drivers')
                .doc(user!.uid)
                .update({'usualRoutes': routes});

            await _loadDriverData();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.routesUpdatedSuccess),
                  backgroundColor: const Color(0xFF00B25E),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setThemeMode(false);

      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Widget _buildVehicleDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Manage Routes Dialog Widget
class _ManageRoutesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> initialRoutes;
  final Function(List<Map<String, dynamic>>) onSave;

  const _ManageRoutesDialog({
    required this.initialRoutes,
    required this.onSave,
  });

  @override
  State<_ManageRoutesDialog> createState() => _ManageRoutesDialogState();
}

class _ManageRoutesDialogState extends State<_ManageRoutesDialog> {
  late List<Map<String, dynamic>> _routes;

  @override
  void initState() {
    super.initState();
    _routes = List<Map<String, dynamic>>.from(widget.initialRoutes);
  }

  void _addRoute() {
    setState(() {
      _routes.add({'route': '', 'price': ''});
    });
  }

  void _removeRoute(int index) {
    setState(() {
      _routes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.manageYourRoutes),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _routes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.route, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noRoutesAdded,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.routeN(index + 1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _removeRoute(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.routeLabel,
                                    hintText: AppLocalizations.of(context)!.routeHint,
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    _routes[index]['route'] = value;
                                  },
                                  controller: TextEditingController(
                                    text: _routes[index]['route'],
                                  )..selection = TextSelection.fromPosition(
                                      TextPosition(
                                          offset:
                                              _routes[index]['route'].length)),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.priceRangeLabel,
                                    hintText: AppLocalizations.of(context)!.priceRangeHint,
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    _routes[index]['price'] = value;
                                  },
                                  controller: TextEditingController(
                                    text: _routes[index]['price'],
                                  )..selection = TextSelection.fromPosition(
                                      TextPosition(
                                          offset:
                                              _routes[index]['price'].length)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addRoute,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addRoute),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00B25E),
                side: const BorderSide(color: Color(0xFF00B25E)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            // Filter out empty routes
            final validRoutes = _routes
                .where((route) =>
                    route['route'].toString().trim().isNotEmpty &&
                    route['price'].toString().trim().isNotEmpty)
                .toList();

            widget.onSave(validRoutes);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B25E),
          ),
          child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
