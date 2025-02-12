import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found - Please login again');

      print('Fetching profile with token: ${token.substring(0, 10)}...'); // Log partial token for debugging

      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Profile Response Status: ${response.statusCode}');
      print('Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - Please login again');
      }
      throw Exception('Failed to load profile: ${response.statusCode}');
    } catch (e) {
      print('Error in getProfile: $e');
      throw Exception('Error getting profile: $e');
    }
  }

  Future<Map<String, dynamic>> getLatestAttempts() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found - Please login again');

      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/quiz-attempt/latest'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Attempts Response Status: ${response.statusCode}');
      print('Attempts Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - Please login again');
      }
      throw Exception('Failed to load quiz attempts: ${response.statusCode}');
    } catch (e) {
      print('Error in getLatestAttempts: $e');
      throw Exception('Error getting quiz attempts: $e');
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String username,
    String? password,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found - Please login again');

      final body = {
        'fullName': fullName,
        'username': username,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.apiUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Session expired - Please login again');
        }
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Error updating profile: $e');
    }
  }
}