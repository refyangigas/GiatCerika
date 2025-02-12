import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/auth/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  Future<Map<String, dynamic>> getLatestAttempts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/quiz-attempt/latest'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load quiz attempts');
    } catch (e) {
      throw Exception('Error getting quiz attempts: $e');
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String username,
    String? password,
  }) async {
    try {
      final body = {
        'fullName': fullName,
        'username': username,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.apiUrl}/auth/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}