import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';

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

  Future<Map<String, String>> _getHeaders({bool withToken = false}) async {
    var headers = {'Content-Type': 'application/json'};
    if (withToken) {
      final token = await _getToken();
      if (token != null) {
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
    headers: await _getHeaders(),
    body: jsonEncode({'email': email, 'password': password}),
  );
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('role', data['role']);
    String token = data['token'];
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    Map<String, dynamic> adminData = decodedToken['data'];
    await prefs.setString('adminData', jsonEncode(adminData)); 
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
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(withToken: true), 
      body: jsonEncode(admin.toJson()),
    );

    if (response.statusCode == 201) {
      return Admin.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add admin: ${response.body}');
    }
  }

  // Get All Admins: GET /admin
  Future<List<Admin>> getAdmins() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _getHeaders(withToken: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Admin.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admins: ${response.body}');
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
    } else {
      throw Exception('Failed to load admin: ${response.body}');
    }
  }

  // Update Admin: PUT /admin/{id}
  Future<Admin> updateAdmin(int id, Admin admin) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(withToken: true),
      body: jsonEncode(admin.toJson()),
    );

    if (response.statusCode == 200) {
      return Admin.fromJson(jsonDecode(response.body));
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

    if (response.statusCode != 200) {
      throw Exception('Failed to delete admin: ${response.body}');
    }
  }
}