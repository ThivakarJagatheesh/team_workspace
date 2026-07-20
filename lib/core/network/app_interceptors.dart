import 'package:dio/dio.dart';

import 'dio_client.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._client);

  final DioClient _client;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!DioClient.shouldRetry(err) ||
        err.requestOptions.extra['retry'] == true) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    requestOptions.extra['retry'] = true;

    try {
      final response = await _client.dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          contentType: requestOptions.contentType,
          responseType: requestOptions.responseType,
          extra: requestOptions.extra,
        ),
      );
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}

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
