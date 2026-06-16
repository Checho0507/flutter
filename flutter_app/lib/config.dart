class AppConfig {
  // Para local:
  // static const String baseUrl = 'http://10.0.2.2:5000';
  
  // Para producción (Railway):
  static const String baseUrl = 'https://workspaceapi-server-production-4343.up.railway.app';
  
  // Helper para construir URLs
  static String getUrl(String path) {
    return '$baseUrl/api$path';
  }
}