import 'dart:convert';

class JwtHelper {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);

    return payloadMap;
  }

  static String? getUserIdFromToken(String token) {
    try {
      final payloadMap = parseJwt(token);
      return payloadMap['user']['id']?.toString();
    } catch (e) {
      print('Error parsing token: $e');
      return null;
    }
  }
}