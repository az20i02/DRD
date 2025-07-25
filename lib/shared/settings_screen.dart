import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../API/api.dart';
import '../API/base.dart';
import '../shared/app_theme.dart';
import 'update_user_info_screen.dart';
import 'app_theme.dart';
import '../Main/welcome_screen.dart';
import '../API/api.dart';
import 'dart:convert';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String? _userName;
  String? _userEmail;
  String? _profileImage;
  bool _isWorker = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _api.readFromStorage('user_data');
      if (userData != null) {
        Map<String, dynamic> userMap;
        
        // Properly handle JSON parsing
        if (userData is String) {
          try {
            userMap = jsonDecode(userData);
          } catch (e) {
            return;
          }
        } else if (userData is Map<String, dynamic>) {
          userMap = userData;
        } else {
          return;
        }
        
        setState(() {
          _userName = userMap['username'];
          _userEmail = userMap['email'];
          _profileImage = userMap['profile_image'];
          _isWorker = userMap['is_worker'] ?? false;
        });
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _logout() async {
    try {
      await _api.logoutUser();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToUpdateProfile() async {
    if (_userName == null) return;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateUserInfoScreen(initialData: {
          'username': _userName,
          'email': _userEmail,
          'is_worker': _isWorker,
        }),
      ),
    );
    if (updated == true) {
      _loadUserData();
    }
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl; // Already a full URL
    }
    // Remove leading slash if present and prepend base URL
    final cleanUrl = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${Config.baseUrl}/$cleanUrl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: _userName == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Card
                Card(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primary,
                          backgroundImage: _profileImage != null && _profileImage != ''
                              ? NetworkImage(_getFullImageUrl(_profileImage!))
                              : null,
                          child: _profileImage == null || _profileImage == ''
                              ? Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimary)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (_userEmail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _userEmail!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Settings Options
                Card(
                  color: theme.colorScheme.surface,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        onTap: _navigateToUpdateProfile,
                      ),
                      Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
                      ListTile(
                        leading: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          isDark ? 'Light Mode' : 'Dark Mode',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        trailing: Switch.adaptive(
                          value: isDark,
                          onChanged: (value) {
                            Provider.of<AppThemeNotifier>(context, listen: false).setDarkMode(value);
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Account Actions
                Card(
                  color: theme.colorScheme.surface,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}