import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../config/api_config.dart';

class VideoService {
  static const int pageSize = 10;

  Future<Map<String, dynamic>> getAllVideos({
    int page = 1,
    String search = '',
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': pageSize.toString(),
        if (search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('${ApiConfig.apiUrl}/video')
          .replace(queryParameters: queryParameters);

      print('Requesting URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          final List<Video> videos = jsonData
              .map((item) => Video.fromJson(item))
              .toList();

          final totalPages = (videos.length / pageSize).ceil();

          return {
            'videos': videos,
            'totalPages': totalPages,
            'currentPage': page,
            'total': videos.length
          };
        } else if (jsonData is Map<String, dynamic>) {
          final List<dynamic> data = jsonData['data'] ?? [];
          final List<Video> videos = data
              .map((item) => Video.fromJson(item))
              .toList();

          return {
            'videos': videos,
            'totalPages': jsonData['totalPages'] ?? 1,
            'currentPage': jsonData['page'] ?? page,
            'total': jsonData['total'] ?? videos.length
          };
        }

        throw Exception('Invalid response format');
      }

      if (response.statusCode == 404) {
        return {
          'videos': [],
          'totalPages': 1,
          'currentPage': page,
          'total': 0
        };
      }

      throw Exception('Failed to load videos: ${response.statusCode}');
    } catch (e) {
      print('Error fetching videos: $e');
      throw Exception('Terjadi kesalahan saat memuat video: $e');
    }
  }

  Future<Video> getVideoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/video/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Video.fromJson(data);
      }

      if (response.statusCode == 404) {
        throw Exception('Video tidak ditemukan');
      }

      throw Exception('Failed to load video detail: ${response.statusCode}');
    } catch (e) {
      print('Error fetching video detail: $e');
      throw Exception('Terjadi kesalahan saat memuat detail video: $e');
    }
  }
}