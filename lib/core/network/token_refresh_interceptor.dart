import 'package:dio/dio.dart';

import 'dio_client.dart';

class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._client);

  final DioClient _client;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!DioClient.shouldRefreshToken(err)) {
      return handler.next(err);
    }

    final token = await _client.getAccessToken();
    if (token == null || token.isEmpty) {
      return handler.next(err);
    }

    err.requestOptions.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _client.dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}
