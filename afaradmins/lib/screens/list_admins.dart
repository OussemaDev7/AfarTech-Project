import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/admin.dart';
import 'add_admin.dart';
import 'admin_layout.dart';

class ListAdminsScreen extends StatefulWidget {
  const ListAdminsScreen({Key? key}) : super(key: key);

  @override
  State<ListAdminsScreen> createState() => _ListAdminsScreenState();
}

class _ListAdminsScreenState extends State<ListAdminsScreen> {
  final ApiService _apiService = ApiService();
  List<Admin> admins = [];
  bool isLoading = true;
  String? errorMessage;
  int? currentAdminId;
  Admin? currentAdmin;

  @override
  void initState() {
    super.initState();
    _loadCurrentAdmin();
    _loadAdmins();
  }

  Future<void> _loadCurrentAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminJson = prefs.getString('adminData');
      if (adminJson != null) {
        final adminData = jsonDecode(adminJson);
        setState(() {
          currentAdminId = adminData['id'] is String 
              ? int.parse(adminData['id']) 
              : adminData['id'];
        });
      }
    } catch (e) {
      print('Error loading current admin: $e');
    }
  }

  Future<void> _loadAdmins() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final list = await _apiService.getAdmins();
      setState(() {
        admins = list;
        // Find current admin from the list
        currentAdmin = list.firstWhere(
          (admin) => admin.id == currentAdminId,
          orElse: () => list.isNotEmpty ? list.first : Admin(),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      
      if (e.toString().contains('Session expired') || 
          e.toString().contains('Token too large') ||
          e.toString().contains('Request header is too large')) {
        _showSessionExpiredDialog();
      } else {
        _showErrorSnackBar('Failed to load admins: $e');
      }
    }
  }


  Widget _buildAdminAvatar(Admin admin, bool isSmallScreen, bool isCurrentUser, bool isSuperAdmin) {
  final image = admin.image;
  
  if (image == null || image.isEmpty) {
    return Container(
      width: isSmallScreen ? 50 : 60,
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green : 
               isSuperAdmin ? Colors.amber : Color(0xFFFF7A3D),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCurrentUser ? Icons.person : 
        isSuperAdmin ? Icons.security : Icons.shield,
        color: Colors.white,
        size: isSmallScreen ? 24 : 28,
      ),
    );
  }

  // Handle network images
  if (image.startsWith('http')) {
    return CircleAvatar(
      radius: isSmallScreen ? 25 : 30,
      backgroundImage: NetworkImage(image),
      child: admin.image == null || admin.image!.isEmpty
          ? Icon(
              isCurrentUser ? Icons.person : 
              isSuperAdmin ? Icons.security : Icons.shield,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            )
          : null,
    );
  }
  
  // Handle file images
  try {
    final filePath = image.replaceFirst('file://', '');
    final file = File(filePath);
    
    if (file.existsSync()) {
      return CircleAvatar(
        radius: isSmallScreen ? 25 : 30,
        backgroundImage: FileImage(file),
        child: admin.image == null || admin.image!.isEmpty
            ? Icon(
                isCurrentUser ? Icons.person : 
                isSuperAdmin ? Icons.security : Icons.shield,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              )
            : null,
      );
    } else {
      // Fallback if file doesn't exist
      return Container(
        width: isSmallScreen ? 50 : 60,
        height: isSmallScreen ? 50 : 60,
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green : 
                 isSuperAdmin ? Colors.amber : Color(0xFFFF7A3D),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCurrentUser ? Icons.person : 
          isSuperAdmin ? Icons.security : Icons.shield,
          color: Colors.white,
          size: isSmallScreen ? 24 : 28,
        ),
      );
    }
  } catch (e) {
    print('Error loading admin image: $e');
    // Fallback on error
    return Container(
      width: isSmallScreen ? 50 : 60,
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green : 
               isSuperAdmin ? Colors.amber : Color(0xFFFF7A3D),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCurrentUser ? Icons.person : 
        isSuperAdmin ? Icons.security : Icons.shield,
        color: Colors.white,
        size: isSmallScreen ? 24 : 28,
      ),
    );
  }
}
  // Separate admins by role and current user
  Admin? get currentUserAdmin => currentAdmin;

  List<Admin> get superAdmins => admins.where((admin) => 
      admin.role == 'SA' && admin.id != currentAdminId).toList();
  
  List<Admin> get regularAdmins => admins.where((admin) => 
      admin.role == 'A' && admin.id != currentAdminId).toList();

  bool isCurrentUser(Admin admin) => admin.id == currentAdminId;

  bool isSuperAdmin(Admin admin) => admin.role == 'SA';

  bool isEditable(Admin admin) {
    // Only regular admins (A) who are not the current user can be edited
    return admin.role == 'A' && !isCurrentUser(admin);
  }

  bool isDeletable(Admin admin) {
    // Only regular admins (A) who are not the current user can be deleted
    return admin.role == 'A' && !isCurrentUser(admin);
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 10),
              Text('Session Expired'),
            ],
          ),
          content: Text('Your session has expired. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutAndReturnToLogin();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutAndReturnToLogin() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _navigateToAddAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAdminScreen()),
    ).then((_) => _loadAdmins());
  }

  void _showEditAdminModal(Admin admin) {
    String firstName = admin.firstName ?? '';
    String lastName = admin.lastName ?? '';
    String email = admin.email ?? '';
    String role = admin.role ?? 'A';
    String password = '';
    bool showPassword = false;
    bool changePassword = false;

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 12),
                  Text(
                    'Edit Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: firstName,
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
                        initialValue: lastName,
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
                        initialValue: email,
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
                      CheckboxListTile(
                        title: Text('Change Password'),
                        value: changePassword,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            changePassword = value ?? false;
                            if (!changePassword) {
                              password = '';
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (changePassword) ...[
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'New Password',
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
                                setDialogState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: !showPassword,
                          validator: (value) {
                            if (changePassword && (value == null || value.isEmpty)) {
                              return 'Please enter a password';
                            }
                            if (changePassword && value!.length < 8) {
                              return 'Minimum 8 characters';
                            }
                            return null;
                          },
                          onChanged: (value) => password = value,
                        ),
                      ],
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        items: <String>['A']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Admin'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            role = newValue ?? role;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final updatedAdmin = Admin(
                          id: admin.id,
                          firstName: firstName,
                          lastName: lastName,
                          email: email,
                          password: changePassword ? password : null,
                          role: role,
                          createdAt: admin.createdAt,
                          updatedAt: DateTime.now(),
                          lastLogin: admin.lastLogin,
                          image: admin.image,
                          notifications: admin.notifications,
                        );
                        
                        final result = await _apiService.updateAdmin(admin.id!, updatedAdmin);
                        setState(() {
                          // Update the admin in the main list
                          final mainIndex = admins.indexWhere((a) => a.id == admin.id);
                          if (mainIndex != -1) {
                            admins[mainIndex] = result;
                          }
                        });
                        Navigator.pop(context);
                        _showSuccessSnackBar('Admin updated successfully!');
                      } catch (e) {
                        if (e.toString().contains('Session expired')) {
                          Navigator.pop(context);
                          _showSessionExpiredDialog();
                        } else {
                          _showErrorSnackBar('Failed to update admin: $e');
                        }
                      }
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAdmin(Admin admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete ${admin.firstName} ${admin.lastName}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await _apiService.deleteAdmin(admin.id!);
                  setState(() {
                    admins.removeWhere((a) => a.id == admin.id);
                  });
                  Navigator.pop(context);
                  _showSuccessSnackBar('Admin deleted successfully!');
                } catch (e) {
                  Navigator.pop(context);
                  if (e.toString().contains('Session expired')) {
                    _showSessionExpiredDialog();
                  } else {
                    _showErrorSnackBar('Failed to delete admin: $e');
                  }
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to Load Admins',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAdmins,
            child: Text('Retry'),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _logoutAndReturnToLogin,
            child: Text('Return to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 380;

    return AdminLayout(
      title: 'Admin Management',
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${superAdmins.length + 1}  super admins • ${regularAdmins.length} admins',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _navigateToAddAdmin,
                  icon: Icon(Icons.add, size: isSmallScreen ? 18 : 20),
                  label: Text(
                    'Add Admin',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Content Section
            Expanded(
              child: isLoading
                  ? _buildLoadingWidget()
                  : errorMessage != null
                      ? _buildErrorWidget()
                      : _buildAdminSections(isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading admins...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSections(bool isSmallScreen) {
    return RefreshIndicator(
      onRefresh: _loadAdmins,
      child: ListView(
        children: [
          // "You" Section - Current User
          if (currentUserAdmin != null) ...[
            _buildSectionHeader('You', Icons.person),
            SizedBox(height: 12),
            _buildAdminCard(currentUserAdmin!, isSmallScreen, true, false),
            SizedBox(height: 24),
          ],

          // Super Admins Section
          if (superAdmins.isNotEmpty) ...[
            _buildSectionHeader('Super Admins', Icons.security),
            SizedBox(height: 12),
            ...superAdmins.map((admin) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAdminCard(admin, isSmallScreen, false, true),
            )),
            SizedBox(height: 24),
          ],

          // Regular Admins Section
          if (regularAdmins.isNotEmpty) ...[
            _buildSectionHeader('Admins', Icons.people),
            SizedBox(height: 12),
            ...regularAdmins.map((admin) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAdminCard(admin, isSmallScreen, false, false),
            )),
          ],

          // Empty state if no admins at all
          if (currentUserAdmin == null && superAdmins.isEmpty && regularAdmins.isEmpty) 
            _buildEmptyWidget(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF6B7280), size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No admins found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first admin to get started',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToAddAdmin,
            child: Text('Add First Admin'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Admin admin, bool isSmallScreen, bool isCurrentUser, bool isSuperAdmin) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentUser ? Colors.green.withOpacity(0.3) : 
                 isSuperAdmin ? Colors.amber.withOpacity(0.3) : Color(0xFFFF7A3D).withOpacity(0.3), 
          width: 2
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Avatar and Basic Info
            Row(
              children: [
                // Avatar
                _buildAdminAvatar(admin, isSmallScreen, isCurrentUser, isSuperAdmin),
                SizedBox(width: isSmallScreen ? 12 : 16),
                
                // Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${admin.firstName ?? ''} ${admin.lastName ?? ''}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        admin.email ?? '',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons - only for regular admins (not current user, not super admins)
                if (isEditable(admin) || isDeletable(admin))
                Row(
                  children: [
                    if (isEditable(admin))
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Color(0xFF6B7280),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => _showEditAdminModal(admin),
                        tooltip: 'Edit',
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        constraints: BoxConstraints(),
                      ),
                    if (isDeletable(admin))
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => _deleteAdmin(admin),
                        tooltip: 'Delete',
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            // Role Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(admin.role ?? ''),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getRoleDisplayName(admin.role ?? ''),
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            // Dates Information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRow(
                  'Created:',
                  _formatDate(admin.createdAt),
                  isSmallScreen,
                ),
                SizedBox(height: 4),
                _buildDateRow(
                  'Modified:',
                  _formatDate(admin.updatedAt),
                  isSmallScreen,
                  isHighlighted: true,
                ),
                SizedBox(height: 4),
                _buildDateRow(
                  'Last Login:',
                  _formatDate(admin.lastLogin),
                  isSmallScreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String date, bool isSmallScreen, {bool isHighlighted = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 11,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            date,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: isHighlighted ? Color(0xFF3B82F6) : Color(0xFF9CA3AF),
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'SA':
        return Colors.amber[700]!;
      case 'A':
        return Colors.blue;
      default:
        return Color(0xFF6B7280);
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'SA':
        return 'Super Admin';
      case 'A':
        return 'Admin';
      default:
        return role;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    return '${date.toLocal().toString().substring(0, 10)}';
  }
}