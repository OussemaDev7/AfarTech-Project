import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';
import '../models/notification.dart' as app_notification;

class EmailNotFoundException implements Exception {
  final String message;
  EmailNotFoundException(this.message);
}

class InvalidPasswordException implements Exception {
  final String message;
  InvalidPasswordException(this.message);
}

class LoginException implements Exception {
  final String message;
  LoginException(this.message);
}

class ApiService {
  static const String baseUrl = 'http://localhost:8081/api/admin';
  static const String loginUrl = '$baseUrl/login';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('adminData');
    await prefs.remove('role');
  }

  Future<Map<String, String>> _getHeaders({bool withToken = false}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withToken) {
      final token = await _getToken();
      if (token != null) {
        // Check if token is too large (usually > 8KB can cause issues)
        if (token.length > 8000) {
          print('Token is too large: ${token.length} bytes, clearing token');
          await _clearToken();
          throw Exception('Token too large, please login again');
        }
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Login: POST /admin/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Sending login request to: $loginUrl');

    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // Store token
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);

      // Decode and store minimal admin data
      String token = data['token'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      Map<String, dynamic> adminData = decodedToken['data'];

      // Store only essential admin data to avoid large tokens
      final minimalAdminData = {
        'id': adminData['id'],
        'firstName': adminData['firstName'],
        'lastName': adminData['lastName'],
        'email': adminData['email'],
        'role': adminData['role'],
        'image': adminData['image'], // Make sure this line exists
      };

      await prefs.setString('adminData', jsonEncode(minimalAdminData));
      return data;
    } else {
      final errorBody = jsonDecode(response.body);
      String errorMsg = errorBody['message'] ?? 'Unknown error';
      if (errorMsg.contains('not found')) {
        throw EmailNotFoundException(errorMsg);
      } else if (errorMsg.contains('Password')) {
        throw InvalidPasswordException(errorMsg);
      } else {
        throw LoginException(errorMsg);
      }
    }
  }

  // Add Admin: POST /admin
  Future<Admin> addAdmin(Admin admin) async {
    final Map<String, dynamic> adminData = {
      'firstName': admin.firstName,
      'lastName': admin.lastName,
      'email': admin.email,
      'password': admin.password,
      'role': admin.role,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(withToken: true),
      body: jsonEncode(adminData),
    );

    if (response.statusCode == 201) {
      return Admin.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      // Token might be too large, try without token
      await _clearToken();
      throw Exception('Session expired, please login again');
    } else {
      throw Exception('Failed to add admin: ${response.body}');
    }
  }

  // Get All Admins: GET /admin
  Future<List<Admin>> getAdmins() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getHeaders(withToken: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Admin.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        // Token might be too large
        await _clearToken();
        throw Exception('Session expired, please login again');
      } else {
        throw Exception(
          'Failed to load admins: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Token too large')) {
        await _clearToken();
        throw Exception('Session expired, please login again');
      }
      rethrow;
    }
  }

  // Get Admin by ID: GET /admin/{id}
  Future<Admin> getAdminById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(withToken: true),
    );

    if (response.statusCode == 200) {
      return Admin.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      await _clearToken();
      throw Exception('Session expired, please login again');
    } else {
      throw Exception('Failed to load admin: ${response.body}');
    }
  }

  // Update Admin: PUT /admin/{id}
  Future<Admin> updateAdmin(int id, Admin admin) async {
    final Map<String, dynamic> updateData = {
      'firstName': admin.firstName,
      'lastName': admin.lastName,
      'email': admin.email,
      'role': admin.role,
    };

    // Only include password if it's provided (for change password)
    if (admin.password != null && admin.password!.isNotEmpty) {
      updateData['password'] = admin.password;
    }

    // Include image if it's provided
    if (admin.image != null && admin.image!.isNotEmpty) {
      updateData['image'] = admin.image;
    }

    print('Sending update request with payload: $updateData');
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(withToken: true),
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Admin.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      await _clearToken();
      throw Exception('Session expired, please login again');
    } else {
      throw Exception('Failed to update admin: ${response.body}');
    }
  }

  // Delete Admin: DELETE /admin/{id}
  Future<void> deleteAdmin(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(withToken: true),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      await _clearToken();
      throw Exception('Session expired, please login again');
    } else {
      throw Exception('Failed to delete admin: ${response.body}');
    }
  }

  // Get Notifications for Admin
  Future<List<app_notification.Notification>> getNotifications(
    int adminId,
  ) async {
    print('Fetching notifications for adminId: $adminId');
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/$adminId/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Notifications response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => app_notification.Notification.fromJson(json))
          .toList();
    } else if (response.statusCode == 400) {
      await _clearToken();
      throw Exception('Session expired, please login again');
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  // Logout - Clear all stored data
  Future<void> logout() async {
    await _clearToken();
  }
}
