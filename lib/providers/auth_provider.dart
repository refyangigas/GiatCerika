import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  DateTime? _lastLoginTime;

  bool get isLoggedIn {
    if (_token == null || _lastLoginTime == null) return false;

    // Check if 5 minutes have passed
    final difference = DateTime.now().difference(_lastLoginTime!);
    if (difference.inMinutes >= 5) {
      logout(); // Auto logout
      return false;
    }
    return true;
  }

  Future<void> setToken(String token) async {
    _token = token;
    _lastLoginTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('lastLoginTime', _lastLoginTime!.toIso8601String());
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _lastLoginTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('lastLoginTime');
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final lastLoginStr = prefs.getString('lastLoginTime');
    if (lastLoginStr != null) {
      _lastLoginTime = DateTime.parse(lastLoginStr);
    }
    notifyListeners();
  }
}
