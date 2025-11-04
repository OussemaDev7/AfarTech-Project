import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';
import '../models/notification.dart' as app_notification;
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import 'edit_profile_screen.dart';
import 'list_admins.dart';
import 'add_admin.dart';

class AdminLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final bool showWelcomeMessage;

  const AdminLayout({
    Key? key,
    required this.title,
    required this.child,
    this.showWelcomeMessage = false,
  }) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final ApiService _apiService = ApiService();
  List<app_notification.Notification> _notifications = [];
  Map<String, dynamic>? _adminData;
  String _welcomeMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadNotifications();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final adminJson = prefs.getString('adminData');
    if (adminJson != null) {
      final adminData = jsonDecode(adminJson);
      setState(() {
        _adminData = adminData;
        _welcomeMessage = 'Welcome back, ${_adminData!['firstName']}!';
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminJson = prefs.getString('adminData');
      if (adminJson != null) {
        final adminData = jsonDecode(adminJson);
        final adminId = adminData['id'] is String
            ? int.parse(adminData['id'])
            : adminData['id'];
        final notifications = await _apiService.getNotifications(adminId);
        setState(() {
          _notifications = notifications;
        });
      }
    } catch (e) {
      setState(() {
        _notifications = [];
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _showProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _adminData?['image'] != null
                  ? (_adminData!['image'].startsWith('http')
                        ? NetworkImage(_adminData!['image'])
                        : FileImage(
                                File(
                                  _adminData!['image'].replaceFirst(
                                    'file://',
                                    '',
                                  ),
                                ),
                              )
                              as ImageProvider)
                  : null,
              child: _adminData?['image'] == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              '${_adminData?['firstName']} ${_adminData?['lastName']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfileScreen(adminData: _adminData!),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Latest Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _notifications.isEmpty
              ? const Text('No notifications yet.')
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(notification.title),
                      subtitle: Text(notification.description),
                      trailing: Text(
                        DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(notification.sentAt),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.showWelcomeMessage 
            ? Text(_welcomeMessage)
            : Text(widget.title),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: themeProvider.toggleTheme,
                tooltip: 'Toggle Theme',
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showProfileDialog(context),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: _adminData?['image'] != null
                  ? (_adminData!['image'].startsWith('http')
                        ? NetworkImage(_adminData!['image'])
                        : FileImage(
                                File(
                                  _adminData!['image'].replaceFirst(
                                    'file://',
                                    '',
                                  ),
                                ),
                              )
                              as ImageProvider)
                  : null,
              child: _adminData?['image'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotificationDialog(context),
                tooltip: 'Notifications',
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: widget.child,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              '${_adminData?['firstName'] ?? ''} ${_adminData?['lastName'] ?? ''}',
            ),
            accountEmail: Text(_adminData?['email'] ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _adminData?['image'] != null
                  ? (_adminData!['image'].startsWith('http')
                        ? NetworkImage(_adminData!['image'])
                        : FileImage(
                                File(
                                  _adminData!['image'].replaceFirst(
                                    'file://',
                                    '',
                                  ),
                                ),
                              )
                                as ImageProvider)
                  : null,
              child: _adminData?['image'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Admins List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListAdminsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients List'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Clients screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Products List'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Products screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories List'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Categories screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Admins Addition'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAdminScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Categories Addition'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Add Category screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Products Addition'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Add Product screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}