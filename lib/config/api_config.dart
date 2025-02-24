class ApiConfig {
  // Base URL untuk server
  static const String baseUrl = 'https://giat-cerika-backend.vercel.app';

  // URL untuk API endpoints
  static const String apiUrl = '$baseUrl/api';

  // Helper method untuk generate URL gambar
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    String normalizedPath = path;
    if (!path.startsWith('/uploads/') && !path.startsWith('uploads/')) {
      normalizedPath =
          path.startsWith('/') ? '/uploads${path}' : '/uploads/$path';
    }

    final fullUrl = '$baseUrl$normalizedPath';
    print('Generated image URL: $fullUrl');

    return fullUrl;
  }
}
