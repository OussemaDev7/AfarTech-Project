import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/admin.dart';
import 'admin_layout.dart';
import 'list_admins.dart'; // Import the admins list screen

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({Key? key}) : super(key: key);

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<void> _addAdmin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newAdmin = Admin(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          role: 'A', // Default role set to "A"
        );
        await _apiService.addAdmin(newAdmin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add admin: $e')),
        );
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _navigateToAdminsList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListAdminsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Add New Admin',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // Header with Admins List button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Admin',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[800],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _navigateToAdminsList,
                  icon: Icon(Icons.list, size: 18),
                  label: Text('Admins List'),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a first name';
                          }
                          return null;
                        },
                        onChanged: (value) => firstName = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a last name';
                          }
                          return null;
                        },
                        onChanged: (value) => lastName = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                        onChanged: (value) => email = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimum 8 characters',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !showPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Minimum 8 characters';
                          }
                          return null;
                        },
                        onChanged: (value) => password = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !showConfirmPassword,
                        validator: _validateConfirmPassword,
                        onChanged: (value) => confirmPassword = value,
                      ),
                      SizedBox(height: 16),
                      // Removed the role dropdown since it defaults to "A"
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'New admin will be created with "Admin" role',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // Centered Add Admin button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(200, 50),
                          ),
                          onPressed: _addAdmin,
                          child: Text(
                            'Add Admin',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}