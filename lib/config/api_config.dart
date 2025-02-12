class ApiConfig {
  // Base URL untuk server
  static const String baseUrl = 'http://192.168.1.7:5000';
  
  // URL untuk API endpoints
  static const String apiUrl = '$baseUrl/api';
  
  // Helper method untuk generate URL gambar
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return ''; // Return empty string for null/empty paths
    }
    
    // Normalisasi path gambar
    String normalizedPath = path;
    if (!path.startsWith('/uploads/') && !path.startsWith('uploads/')) {
      normalizedPath = path.startsWith('/')
          ? '/uploads${path}'
          : '/uploads/$path';
    }
    
    // Generate full URL
    final fullUrl = '$baseUrl$normalizedPath';
    
    // Debug: Print generated URL
    print('Generated image URL: $fullUrl');
    
    return fullUrl;
  }
}