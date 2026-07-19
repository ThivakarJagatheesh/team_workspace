import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/flavor.dart';
import '../constants/app_constants.dart';

/// Configured [Dio] instance. Centralises base URL, timeouts and logging so
/// data sources stay thin.
class DioClient {
  DioClient() : dio = Dio(_baseOptions) {
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
}
