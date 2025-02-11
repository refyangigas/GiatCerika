import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/materi.dart';
import '../config/api_config.dart';

class MateriService {
  static const int pageSize = 10;

  Future<Map<String, dynamic>> getAllMateri(
      {int page = 1, String search = ''}) async {
    try {
      // Buat query parameters
      final queryParameters = {
        'page': page.toString(),
        'limit': pageSize.toString(),
        if (search.isNotEmpty) 'search': search, // Parameter search
      };

      // Buat URI dengan query parameters
      final uri = Uri.parse('${ApiConfig.apiUrl}/materi')
          .replace(queryParameters: queryParameters);

      // Debug: Print URL
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
          // Handle array response
          final List<Materi> materis = jsonData
              .map((item) => Materi(
                    id: item['_id'] ?? '',
                    judul: item['judul'] ?? '',
                    konten: item['konten'] ?? '',
                    thumbnail: ApiConfig.getImageUrl(item['thumbnail']),
                    createdAt: item['createdAt'] != null
                        ? DateTime.parse(item['createdAt'])
                        : DateTime.now(),
                  ))
              .toList();

          // Hitung total pages berdasarkan jumlah data
          final totalPages = (materis.length / pageSize).ceil();

          return {
            'materis': materis,
            'totalPages': totalPages,
            'currentPage': page,
            'total': materis.length
          };
        } else if (jsonData is Map<String, dynamic>) {
          // Handle object response with data property
          final List<dynamic> data = jsonData['data'] ?? [];
          final List<Materi> materis = data
              .map((item) => Materi(
                    id: item['_id'] ?? '',
                    judul: item['judul'] ?? '',
                    konten: item['konten'] ?? '',
                    thumbnail: ApiConfig.getImageUrl(item['thumbnail']),
                    createdAt: item['createdAt'] != null
                        ? DateTime.parse(item['createdAt'])
                        : DateTime.now(),
                  ))
              .toList();

          return {
            'materis': materis,
            'totalPages': jsonData['totalPages'] ?? 1,
            'currentPage': jsonData['page'] ?? page,
            'total': jsonData['total'] ?? materis.length
          };
        }

        throw Exception('Invalid response format');
      }

      if (response.statusCode == 404) {
        return {
          'materis': [],
          'totalPages': 1,
          'currentPage': page,
          'total': 0
        };
      }

      throw Exception('Failed to load materi: ${response.statusCode}');
    } catch (e) {
      print('Error fetching materis: $e');
      throw Exception('Terjadi kesalahan saat memuat materi: $e');
    }
  }

  Future<Materi> getMateriById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/materi/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final thumbnailUrl = ApiConfig.getImageUrl(data['thumbnail']);
        print('Generated thumbnail URL: $thumbnailUrl');

        return Materi(
          id: data['_id'] ?? '',
          judul: data['judul'] ?? '',
          konten: data['konten'] ?? '',
          thumbnail: thumbnailUrl,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
        );
      }

      if (response.statusCode == 404) {
        throw Exception('Materi tidak ditemukan');
      }

      throw Exception('Failed to load materi detail: ${response.statusCode}');
    } catch (e) {
      print('Error fetching materi detail: $e');
      throw Exception('Terjadi kesalahan saat memuat detail materi: $e');
    }
  }
}
