import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../config/api_config.dart';

class QuizService {
  static const int pageSize = 10;

  Future<Map<String, dynamic>> getAllQuizzes({
    int page = 1,
    String search = '',
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': pageSize.toString(),
        if (search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('${ApiConfig.apiUrl}/quiz')
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

        // Handle both array and paginated object responses
        if (jsonData is List) {
          final List<Quiz> quizzes =
              jsonData.map((item) => Quiz.fromJson(item)).toList();

          return {
            'quizzes': quizzes,
            'totalPages': (quizzes.length / pageSize).ceil(),
            'currentPage': page,
            'total': quizzes.length
          };
        } else if (jsonData is Map<String, dynamic>) {
          final List<dynamic> data = jsonData['data'] ?? [];
          final List<Quiz> quizzes =
              data.map((item) => Quiz.fromJson(item)).toList();

          return {
            'quizzes': quizzes,
            'totalPages': jsonData['totalPages'] ?? 1,
            'currentPage': jsonData['page'] ?? page,
            'total': jsonData['total'] ?? quizzes.length
          };
        }

        throw Exception('Invalid response format');
      }

      if (response.statusCode == 404) {
        return {
          'quizzes': [],
          'totalPages': 1,
          'currentPage': page,
          'total': 0
        };
      }

      throw Exception('Failed to load quizzes: ${response.statusCode}');
    } catch (e) {
      print('Error fetching quizzes: $e');
      throw Exception('Terjadi kesalahan saat memuat quiz: $e');
    }
  }

  Future<Quiz> getQuizById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/quiz/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quiz.fromJson(data);
      }

      if (response.statusCode == 404) {
        throw Exception('Quiz tidak ditemukan');
      }

      throw Exception('Failed to load quiz detail: ${response.statusCode}');
    } catch (e) {
      print('Error fetching quiz detail: $e');
      throw Exception('Terjadi kesalahan saat memuat detail quiz: $e');
    }
  }

  Future<Map<String, dynamic>> submitQuizAttempt({
    required String quizId,
    required String userId,
    required List<Map<String, dynamic>> answers,
    required int score,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConfig.apiUrl}/quiz-attempt/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user': userId,
          'quiz': quizId,
          'answers': answers,
          'score': score,
        }),
      )
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }

      throw Exception('Failed to submit quiz attempt: ${response.statusCode}');
    } catch (e) {
      print('Error submitting quiz attempt: $e');
      throw Exception('Terjadi kesalahan saat mengirim hasil quiz: $e');
    }
  }
}
