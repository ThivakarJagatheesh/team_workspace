import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/flavor.dart';
import '../constants/app_constants.dart';
import 'app_interceptors.dart';

/// Configured [Dio] instance. Centralises base URL, timeouts and logging so
/// data sources stay thin.
class DioClient {
  DioClient() : dio = Dio(_baseOptions) {
    dio.interceptors.add(RetryInterceptor(this));
    dio.interceptors.add(TokenRefreshInterceptor(this));

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
