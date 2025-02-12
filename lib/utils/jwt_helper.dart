import 'dart:convert';

class JwtHelper {
  static Map<String, dynamic> parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format: token should have 3 parts');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      
      print('Decoded payload structure: ${payloadMap.keys.join(', ')}');
      return payloadMap;
    } catch (e) {
      print('Error in parseJwt: $e');
      rethrow;
    }
  }

  static String? getUserIdFromToken(String token) {
    try {
      final payloadMap = parseJwt(token);
      
      // Debug logs
      print('Payload map: $payloadMap');
      
      // ID berada langsung di root payload
      final userId = payloadMap['id']?.toString();
      if (userId == null) {
        throw Exception('User ID not found in token payload');
      }
      
      return userId;
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }
}