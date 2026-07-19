import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_workspace/core/network/dio_client.dart';

void main() {
  group('DioClient retry helpers', () {
    test('detects retryable transient failures', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/tasks'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(DioClient.shouldRetry(error), isTrue);
    });

    test('detects unauthorized responses that should trigger token refresh',
        () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/tasks'),
        response: Response(
          requestOptions: RequestOptions(path: '/tasks'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(DioClient.shouldRefreshToken(error), isTrue);
    });
  });
}
