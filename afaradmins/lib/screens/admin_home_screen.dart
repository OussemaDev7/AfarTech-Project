import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/api_service.dart';  
import '../providers/theme_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? _adminData;
  String _welcomeMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear token, role, adminData
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');  // Back to login (use '/' for home in main.dart)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(_welcomeMessage),
  actions: [
    // Dark/Light Toggle
    Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeProvider.toggleTheme,
          tooltip: 'Toggle Theme',
        );
      },
    ),
    const SizedBox(width: 8),
    // More actions next...
  ],
),
      body: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Admin Dashboard - Coming Soon!'),
          ),
        ),
      ),
    );
  }
}