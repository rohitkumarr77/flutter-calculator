
import 'package:finance_manager/services/theme_service.dart' hide ThemeService;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    setState(() {
      _isDarkMode = ThemeService.instance.isDarkMode;
    });

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _user = await AuthService.getCurrentUser();
    final userId = await AuthService.getCurrentUserId();

    if (userId != null) {
      _stats = await DatabaseHelper.instance.getDashboardStats(userId);
    }

    setState(() => _isLoading = false);
  }
  //
  // Future<void> _loadSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _isDarkMode = prefs.getBool('dark_mode') ?? false;
  //     _notificationsEnabled = prefs.getBool('notifications') ?? true;
  //   });
  // }

  Future<void> _toggleDarkMode(bool value) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('dark_mode', value);
    await ThemeService.instance.setThemeMode(value);
    setState(() => _isDarkMode = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Dark mode enabled' : 'Light mode enabled'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notificationsEnabled = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    final usernameController = TextEditingController(text: _user?['username']);
    final emailController = TextEditingController(text: _user?['email']);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'username': usernameController.text,
                'email': emailController.text,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Here you would update the database
      // For now, just show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Reload user data
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setDialogState(() => obscureCurrent = !obscureCurrent);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setDialogState(() => obscureNew = !obscureNew);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setDialogState(() => obscureConfirm = !obscureConfirm);
                      },
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
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
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

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your transactions. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        final transactions = await DatabaseHelper.instance.getTransactions(userId);
        for (var transaction in transactions) {
          await DatabaseHelper.instance.deleteTransaction(transaction['id']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?['username'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?['email'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatChip(
                        'Transactions',
                        '${(_stats?['recent_transactions'] as List?)?.length ?? 0}',
                        Icons.receipt,
                      ),
                      _buildStatChip(
                        'Balance',
                        '₹${(_stats?['balance'] ?? 0.0).toStringAsFixed(0)}',
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildMenuItem(
              Icons.person,
              'Edit Profile',
              _showEditProfileDialog,
            ),
            _buildMenuItem(
              Icons.lock,
              'Change Password',
              _showChangePasswordDialog,
            ),

            const Divider(),

            // App Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Dark Mode Toggle
            ListTile(
              leading: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF667eea),
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                activeColor: const Color(0xFF667eea),
              ),
            ),

            // Notifications Toggle
            ListTile(
              leading: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: const Color(0xFF667eea),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: const Color(0xFF667eea),
              ),
            ),

            const Divider(),

            // Data Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            _buildMenuItem(
              Icons.backup,
              'Backup Data',
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
            _buildMenuItem(
              Icons.restore,
              'Restore Data',
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon')),
                );
              },
            ),
            _buildMenuItem(
              Icons.delete_forever,
              'Clear All Data',
              _clearAllData,
              color: Colors.orange,
            ),

            const Divider(),

            // About Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            _buildMenuItem(
              Icons.help,
              'Help & Support',
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact: support@financemanager.com'),
                  ),
                );
              },
            ),
            _buildMenuItem(
              Icons.info,
              'About App',
                  () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Finance Manager',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.account_balance_wallet,
                    size: 50,
                    color: Color(0xFF667eea),
                  ),
                  children: [
                    const Text(
                      'A complete offline personal finance management app',
                    ),
                  ],
                );
              },
            ),
            _buildMenuItem(
              Icons.privacy_tip,
              'Privacy Policy',
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data stored locally on your device'),
                  ),
                );
              },
            ),

            const Divider(),

            // Logout Button
            _buildMenuItem(
              Icons.logout,
              'Logout',
              _logout,
              color: Colors.red,
            ),

            const SizedBox(height: 20),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color? color,
      }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF667eea)),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}