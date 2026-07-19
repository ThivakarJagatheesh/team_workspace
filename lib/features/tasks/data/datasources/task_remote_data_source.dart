import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

/// Fetches tasks from the REST API with `?_page=&_limit=` pagination.
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks({required int page, required int limit});
  Future<TaskModel> updateTask(TaskModel task);
  Future<TaskModel> createTask(TaskModel task);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<TaskModel>> getTasks({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        AppConstants.tasksEndpoint,
        queryParameters: {'_page': page, '_limit': limit},
      );

      final data = response.data ?? const [];
      return data
          .cast<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Failed to load tasks');
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      // The demo API echoes the body back (it doesn't persist). A real API
      // would return the saved record.
      await _client.dio.put<Map<String, dynamic>>(
        '${AppConstants.tasksEndpoint}/${task.id}',
        data: task.toJson(),
      );
      return task;
    } on DioException catch (e) {
      throw _mapDio(e, 'Failed to update task');
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        AppConstants.tasksEndpoint,
        data: task.toJson(),
      );
      // Demo API returns a fresh id but doesn't persist; we keep our local id
      // so the created task is stable across reloads.
      return task;
    } on DioException catch (e) {
      throw _mapDio(e, 'Failed to create task');
    } catch (_) {
      throw ServerException();
    }
  }

  Exception _mapDio(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException();
    }
    return ServerException(e.message ?? fallback);
  }
}
