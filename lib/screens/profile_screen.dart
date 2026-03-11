// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/locale_provider.dart';
import '../services/history_service.dart';
import '../services/ride_service.dart';
import '../services/swap_service.dart';
import '../utils/user_helper.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          l10n.profile,
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
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF00B25E),
                    child: Text(
                      (user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B25E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.student,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00B25E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Section
            _buildSection(
              context,
              l10n.settings,
              [
                _buildSettingTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: l10n.darkMode,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.setThemeMode(value),
                    activeColor: const Color(0xFF00B25E),
                  ),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.language_outlined,
                  title: l10n.language,
                  subtitle: localeProvider.currentLanguageName,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),

            // Account Section
            _buildSection(
              context,
              l10n.account,
              [
                _buildSettingTile(
                  context,
                  icon: Icons.person_outline,
                  title: l10n.editProfile,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(context, user),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.lock_outline,
                  title: l10n.changePassword,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.history,
                  title: l10n.userHistory,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUserHistoryDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.pending_actions_outlined,
                  title: l10n.myPendingRequests,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPendingRequestsDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.logout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: LocaleProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final language = LocaleProvider.supportedLanguages.keys.elementAt(index);
              final isSelected = localeProvider.currentLanguageName == language;
              return ListTile(
                title: Text(language),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF00B25E))
                    : null,
                selected: isSelected,
                onTap: () async {
                  await localeProvider.setLocale(language);
                  if (context.mounted) {
                    Navigator.pop(context);
                    final newL10n = AppLocalizations.of(context)!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newL10n.languageChanged(language)),
                        backgroundColor: const Color(0xFF00B25E),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User? user) {
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await user?.updateDisplayName(nameController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Color(0xFF00B25E),
                    ),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B25E),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
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
                  labelText: 'New Password',
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
                  labelText: 'Confirm New Password',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
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
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Color(0xFF00B25E),
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
            child: const Text('Change Password',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserHistoryDialog(BuildContext context) {
    final HistoryService historyService = HistoryService();
    final RideService rideService = RideService();
    final SwapService swapService = SwapService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'All your rides, bookings, trades & swaps',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: UserHelper.getCurrentSupabaseUser(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (userSnapshot.hasError || !userSnapshot.hasData) {
                        return Center(
                          child: Text('Could not load user info',
                              style: TextStyle(color: Colors.grey[500])),
                        );
                      }

                      final userId =
                          userSnapshot.data!['user_id'] as String;

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: _buildFullHistory(
                            userId, historyService, rideService, swapService),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.grey[500])),
                            );
                          }

                          final history = snapshot.data ?? [];
                          if (history.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history,
                                      size: 56, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text('No history yet',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Your activity will appear here',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13)),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              return _buildHistoryCard(
                                  context, history[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a unified history list from all sources
  Future<List<Map<String, dynamic>>> _buildFullHistory(
    String userId,
    HistoryService historyService,
    RideService rideService,
    SwapService swapService,
  ) async {
    List<Map<String, dynamic>> allItems = [];

    // 1. Ticket trade history (completed trades from tickets_history table)
    try {
      final ticketHistory = await historyService.getUserHistory(userId);
      for (var item in ticketHistory) {
        allItems.add({
          'type': 'trade',
          'category': (item['trade_type'] as String?) ?? 'trade',
          'status': (item['status'] as String?) ?? 'completed',
          'from': item['from_location'] ?? '',
          'to': item['to_location'] ?? '',
          'date': item['ride_date'] ?? item['completed_at'] ?? '',
          'price': (item['price'] as num?)?.toDouble(),
          'description': item['description'],
          'timestamp': item['completed_at'] ?? '',
        });
      }
    } catch (_) {}

    // 2. User's ride postings (all statuses)
    try {
      final rides = await rideService.getUserRides(userId);
      for (var ride in rides) {
        allItems.add({
          'type': 'ride_posted',
          'category': 'ride',
          'status': (ride['status'] as String?) ?? 'active',
          'from': ride['from_location'] ?? '',
          'to': ride['to_location'] ?? '',
          'date': ride['ride_date'] ?? '',
          'time': ride['ride_time'] ?? '',
          'price': (ride['price_per_seat'] as num?)?.toDouble(),
          'seats': ride['available_seats'],
          'timestamp': ride['created_at'] ?? '',
        });
      }
    } catch (_) {}

    // 3. User's bookings (all statuses including rejected/cancelled)
    try {
      final bookings = await rideService.getUserBookings(userId);
      for (var booking in bookings) {
        allItems.add({
          'type': 'booking',
          'category': 'booking',
          'status': (booking['status'] as String?) ?? 'pending',
          'from': booking['from_location'] ?? '',
          'to': booking['to_location'] ?? '',
          'date': booking['ride_date'] ?? '',
          'time': booking['ride_time'] ?? '',
          'price': (booking['total_price'] as num?)?.toDouble(),
          'poster_name': booking['poster_name'] ?? '',
          'timestamp': booking['created_at'] ?? '',
        });
      }
    } catch (_) {}

    // 4. Swap requests sent by user (all statuses)
    try {
      final sentSwaps = await swapService.getSentRequests(userId).first;
      for (var swap in sentSwaps) {
        allItems.add({
          'type': 'swap_sent',
          'category': 'swap',
          'status': swap.status,
          'message': swap.message ?? '',
          'date': swap.createdAt.toIso8601String().split('T')[0],
          'timestamp': swap.createdAt.toIso8601String(),
        });
      }
    } catch (_) {}

    // 5. Swap requests received by user (all statuses)
    try {
      final receivedSwaps =
          await swapService.getReceivedRequests(userId).first;
      for (var swap in receivedSwaps) {
        allItems.add({
          'type': 'swap_received',
          'category': 'swap',
          'status': swap.status,
          'requester': swap.requesterName ?? 'Unknown',
          'message': swap.message ?? '',
          'date': swap.createdAt.toIso8601String().split('T')[0],
          'timestamp': swap.createdAt.toIso8601String(),
        });
      }
    } catch (_) {}

    // Sort by timestamp descending (most recent first)
    allItems.sort((a, b) {
      final aTime = a['timestamp'] as String? ?? '';
      final bTime = b['timestamp'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return allItems;
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    final type = item['type'] as String;
    final category = item['category'] as String;
    final status = item['status'] as String;
    final from = item['from'] as String? ?? '';
    final to = item['to'] as String? ?? '';
    final date = item['date'] as String? ?? '';
    final price = item['price'] as double?;

    // Status colors
    Color statusColor;
    switch (status) {
      case 'completed':
      case 'confirmed':
      case 'accepted':
        statusColor = const Color(0xFF00B25E);
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'active':
      case 'full':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Category icon and label
    IconData categoryIcon;
    String categoryLabel;
    Color categoryColor;
    switch (type) {
      case 'ride_posted':
        categoryIcon = Icons.directions_car;
        categoryLabel = 'RIDE POSTED';
        categoryColor = Colors.blue;
        break;
      case 'booking':
        categoryIcon = Icons.confirmation_num;
        categoryLabel = 'BOOKING';
        categoryColor = Colors.purple;
        break;
      case 'swap_sent':
        categoryIcon = Icons.swap_horiz;
        categoryLabel = 'SWAP SENT';
        categoryColor = Colors.teal;
        break;
      case 'swap_received':
        categoryIcon = Icons.swap_horiz;
        categoryLabel = 'SWAP RECEIVED';
        categoryColor = Colors.indigo;
        break;
      default:
        categoryIcon = Icons.receipt;
        categoryLabel = category.toUpperCase();
        categoryColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon,
                            size: 12, color: categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          categoryLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                date.length > 10 ? date.substring(0, 10) : date,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          if (from.isNotEmpty || to.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: const Color(0xFF00B25E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$from → $to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (type == 'swap_sent' || type == 'swap_received') ...[
            const SizedBox(height: 8),
            Text(
              type == 'swap_received'
                  ? 'From: ${item['requester'] ?? 'Unknown'}'
                  : (item['message'] as String? ?? '').isNotEmpty
                      ? 'Message: ${item['message']}'
                      : 'Swap request',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          if (type == 'booking' &&
              (item['poster_name'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ride by ${item['poster_name']}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          if (price != null && price > 0) ...[
            const SizedBox(height: 4),
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00B25E),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPendingRequestsDialog(BuildContext context) {
    final RideService rideService = RideService();
    final SwapService swapService = SwapService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Pending Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cancel pending ride bookings and swap requests',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: UserHelper.getCurrentSupabaseUser(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (userSnapshot.hasError ||
                              !userSnapshot.hasData) {
                            return Center(
                              child: Text('Could not load user info',
                                  style:
                                      TextStyle(color: Colors.grey[500])),
                            );
                          }

                          final userId =
                              userSnapshot.data!['user_id'] as String;

                          return FutureBuilder<List<Map<String, dynamic>>>(
                            future: _buildPendingRequests(
                                userId, rideService, swapService),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final pending = snapshot.data ?? [];
                              if (pending.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          size: 56,
                                          color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text('No pending requests',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'All caught up!',
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 13)),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                controller: scrollController,
                                itemCount: pending.length,
                                itemBuilder: (context, index) {
                                  final item = pending[index];
                                  return _buildPendingCard(
                                    context,
                                    item,
                                    rideService,
                                    swapService,
                                    () {
                                      // Refresh after cancel
                                      setSheetState(() {});
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _buildPendingRequests(
    String userId,
    RideService rideService,
    SwapService swapService,
  ) async {
    List<Map<String, dynamic>> pending = [];

    // Pending ride bookings
    try {
      final bookings = await rideService.getUserBookings(userId);
      for (var b in bookings) {
        if (b['status'] == 'pending') {
          pending.add({
            'type': 'booking',
            'id': b['booking_id'],
            'from': b['from_location'] ?? '',
            'to': b['to_location'] ?? '',
            'date': b['ride_date'] ?? '',
            'time': b['ride_time'] ?? '',
            'price': (b['total_price'] as num?)?.toDouble(),
            'poster_name': b['poster_name'] ?? '',
          });
        }
      }
    } catch (_) {}

    // Pending swap requests sent
    try {
      final swaps = await swapService.getSentRequests(userId).first;
      for (var s in swaps) {
        if (s.status == 'pending') {
          pending.add({
            'type': 'swap',
            'id': s.requestId,
            'message': s.message ?? '',
            'date': s.createdAt.toIso8601String().split('T')[0],
          });
        }
      }
    } catch (_) {}

    return pending;
  }

  Widget _buildPendingCard(
    BuildContext context,
    Map<String, dynamic> item,
    RideService rideService,
    SwapService swapService,
    VoidCallback onCancelled,
  ) {
    final type = item['type'] as String;
    final isBooking = type == 'booking';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isBooking ? Colors.purple : Colors.teal)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isBooking ? 'RIDE BOOKING' : 'SWAP REQUEST',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isBooking ? Colors.purple : Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                item['date'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isBooking) ...[
            Text(
              '${item['from']} → ${item['to']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if ((item['poster_name'] as String? ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Ride by ${item['poster_name']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            if (item['price'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '₹${(item['price'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00B25E),
                  ),
                ),
              ),
          ] else ...[
            Text(
              (item['message'] as String? ?? '').isNotEmpty
                  ? 'Message: ${item['message']}'
                  : 'Swap request',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                try {
                  if (isBooking) {
                    await rideService.cancelBooking(item['id']);
                  } else {
                    await swapService.cancelSwapRequest(item['id']);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request cancelled'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    onCancelled();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel Request',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Reset theme to light mode before logout
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setThemeMode(false);

      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
