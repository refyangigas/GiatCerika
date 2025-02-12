import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:giat_cerika/utils/jwt_helper.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _userId;

  String? get userId => _userId;
  String? get token => _token;

  bool get isLoggedIn => _token != null;

  Future<void> setToken(String token) async {
    try {
      _token = token;
      _userId = JwtHelper.getUserIdFromToken(token);
      await _storage.write(key: 'token', value: token);
      notifyListeners();
    } catch (e) {
      print('Error setting token: $e');
      throw Exception('Failed to save token');
    }
  }

  Future<void> logout() async {
    try {
      _token = null;
      _userId = null;
      await _storage.delete(key: 'token');
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout');
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      _token = await _storage.read(key: 'token');
      if (_token != null) {
        _userId = JwtHelper.getUserIdFromToken(_token!);
      }
      notifyListeners();
    } catch (e) {
      print('Error checking login status: $e');
      await logout(); // Clear any potentially corrupted state
    }
  }
}