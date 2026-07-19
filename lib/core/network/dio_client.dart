import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/flavor.dart';
import '../constants/app_constants.dart';

/// Configured [Dio] instance. Centralises base URL, timeouts and logging so
/// data sources stay thin.
class DioClient {
  DioClient() : dio = Dio(_baseOptions) {
    dio.interceptors.add(_RetryInterceptor(this));
    dio.interceptors.add(_TokenRefreshInterceptor(this));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }
  }

  final Dio dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: FlavorConfig.instance.baseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    responseType: ResponseType.json,
    headers: {'Content-Type': 'application/json'},
  );

  static bool shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  static bool shouldRefreshToken(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  Future<String?> getAccessToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._client);

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
    } catch (e) {
      return handler.next(err);
    }
  }
}

class _TokenRefreshInterceptor extends Interceptor {
  _TokenRefreshInterceptor(this._client);

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
    } catch (e) {
      return handler.next(err);
    }
  }
}
