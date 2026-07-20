import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static Future<void> load([String? fileName]) async => dotenv.load(fileName: fileName ?? '.env');

  static String get devBaseUrl =>
      dotenv.env['DEV_BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';

  static String get prodBaseUrl =>
      dotenv.env['PROD_BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';

  static String get tasksEndpoint => dotenv.env['TASKS_ENDPOINT'] ?? '/todos';
}
