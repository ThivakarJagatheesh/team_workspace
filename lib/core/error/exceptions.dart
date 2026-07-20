

class ServerException implements Exception {
  ServerException([this.message = 'Server error']);
  final String message;
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection']);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error']);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}

/// Wraps FirebaseAuthException codes with a human-readable message.
class AuthException implements Exception {
  AuthException([this.message = 'Authentication error']);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}
