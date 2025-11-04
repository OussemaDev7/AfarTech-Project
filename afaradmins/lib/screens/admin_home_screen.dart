import 'package:flutter/material.dart';
import 'admin_layout.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Dashboard',
      showWelcomeMessage: true,
      child: Center(
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