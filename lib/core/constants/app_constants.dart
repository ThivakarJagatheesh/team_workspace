/// App-wide constants. Keep secrets OUT of here — use env / Firebase config.
class AppConstants {
  AppConstants._();

  static const String appName = 'Team Workspace';

  // ── API ──────────────────────────────────────────────────
  // A public mock REST API that supports ?_page=&_limit= pagination.
  // Swap for your own endpoint if needed.
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String tasksEndpoint = '/todos';
  static const int pageSize = 15;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Local storage keys ───────────────────────────────────
  static const String sessionBox = 'session_box';
  static const String tasksBox = 'tasks_box';
  static const String outboxBox = 'outbox_box'; // offline change queue

  static const String kIsLoggedIn = 'is_logged_in';
  static const String kUserId = 'user_id';
  static const String kUserEmail = 'user_email';

  // Fallback bundled data when the API is unreachable.
  static const String tasksAssetPath = 'assets/data/tasks.json';
}
