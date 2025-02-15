import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://giat-cerika-backend.vercel.app';

  Future<Map<String, dynamic>> register(
      String fullName, String username, String password) async {
    try {
      print('Sending register request to: $baseUrl/auth/register');
      print('Request body: ${jsonEncode({
            'fullname': fullName,
            'username': username,
            'password': password,
          })}');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('Error during registration: $e');
      return {'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Sending login request to: $baseUrl/auth/login');
      print('Request body: ${jsonEncode({
            'username': username,
            'password': password,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('Error during login: $e');
      return {'message': 'Terjadi kesalahan: $e'};
    }
  }
}
