import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/admin.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> adminData;

  const EditProfileScreen({super.key, required this.adminData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _hasNewImage = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.adminData['firstName']);
    _lastNameController = TextEditingController(text: widget.adminData['lastName']);
    _emailController = TextEditingController(text: widget.adminData['email']);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _convertImageToBase64(XFile image) async {
    try {
      if (kIsWeb) {
        // For web, handle differently if needed
        final bytes = await image.readAsBytes();
        return base64Encode(bytes);
      }
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce size
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _hasNewImage = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Helper method to get image provider for display
  ImageProvider? _getImageProvider() {
    // If user selected a new image
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    }
    
    // If there's an existing image
    final existingImage = widget.adminData['image'];
    if (existingImage != null && existingImage.isNotEmpty) {
      // Handle network images
      if (existingImage.startsWith('http')) {
        return NetworkImage(existingImage);
      }
      // Handle base64 images
      else {
        try {
          // Check if it's a valid base64 string
          if (existingImage.length > 100 && !existingImage.contains(' ')) {
            final bytes = base64Decode(existingImage);
            return MemoryImage(bytes);
          } else {
            // Might be a file path or invalid base64
            return null;
          }
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      }
    }
    
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminId = widget.adminData['id'] is String
          ? int.parse(widget.adminData['id'])
          : widget.adminData['id'];

      String? updatedImage;

      // Only process image if a new one was selected
      if (_hasNewImage && _selectedImage != null) {
        print('Converting new image to base64...');
        updatedImage = await _convertImageToBase64(_selectedImage!);
        if (updatedImage != null) {
          print('Image converted successfully, length: ${updatedImage.length}');
        } else {
          print('Failed to convert image');
        }
      } else {
        // Keep existing image as is
        updatedImage = widget.adminData['image'];
        print('Keeping existing image');
      }

      // Create updated Admin object
      final updatedAdmin = Admin(
        id: adminId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        image: updatedImage,
        role: widget.adminData['role'],
        createdAt: widget.adminData['createdAt'] != null 
            ? DateTime.tryParse(widget.adminData['createdAt']) 
            : null,
        updatedAt: DateTime.now(),
        lastLogin: widget.adminData['lastLogin'] != null
            ? DateTime.tryParse(widget.adminData['lastLogin'])
            : null,
      );

      print('Sending update with image data: ${updatedImage != null ? "YES" : "NO"}');
      final result = await _apiService.updateAdmin(adminId, updatedAdmin);
      
      print('Update successful, received: ${result.toJson()}');

      // Update SharedPreferences with the complete admin data from response
      final prefs = await SharedPreferences.getInstance();
      final updatedAdminData = {
        'id': adminId,
        'firstName': result.firstName ?? _firstNameController.text,
        'lastName': result.lastName ?? _lastNameController.text,
        'email': result.email ?? _emailController.text,
        'role': result.role ?? widget.adminData['role'],
        'image': result.image ?? updatedImage, // Use image from response if available
      };
      
      await prefs.setString('adminData', jsonEncode(updatedAdminData));

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      
      // Delay a bit to show the success message
      await Future.delayed(Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingImage = widget.adminData['image'] != null && 
                            widget.adminData['image'].isNotEmpty;
    final hasSelectedImage = _selectedImage != null;
    final showDefaultIcon = !hasExistingImage && !hasSelectedImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Image with better handling
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _getImageProvider(),
                        child: showDefaultIcon
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      if (_hasNewImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Change Profile Picture Button
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera_alt),
                  label: const Text('Change Profile Picture'),
                ),
                const SizedBox(height: 16),
                
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password (Optional)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Leave blank to keep current password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Save Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text('Save Changes'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}