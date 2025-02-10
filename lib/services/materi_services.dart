// lib/services/materi_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/materi.dart';

class MateriService {
  static const String baseUrl = 'http://192.168.1.2:5000/api';
  static const int pageSize = 10;

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    // Remove leading slash if exists
    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return 'http://192.168.1.2:5000/$cleanPath';
  }

 Future<Map<String, dynamic>> getAllMateri({int page = 1, String search = ''}) async {
  try {
    final queryParameters = {
      'page': page.toString(),
      'limit': pageSize.toString(),
      if (search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse('$baseUrl/materi').replace(queryParameters: queryParameters);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      
      return {
        'materis': responseData,
        'totalPages': 1,
        'currentPage': page,
        'total': responseData.length,
      };
    } else {
      throw Exception('Failed to load materi');
    }
  } catch (e) {
    print('Error fetching materis: $e');
    throw Exception('Terjadi kesalahan: $e');
  }
}

  Future<Materi> getMateriById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materi/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Materi.fromJson({
          ...data,
          'thumbnail': _getFullImageUrl(data['thumbnail']),
        });
      } else {
        throw Exception('Failed to load materi detail');
      }
    } catch (e) {
      print('Error fetching materi detail: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
