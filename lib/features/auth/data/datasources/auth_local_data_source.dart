import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Persists the signed-in user locally so the session survives an app restart
/// even before Firebase re-hydrates (and works as the offline session record).
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getCachedUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _kUser = 'cached_user';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _prefs.setString(_kUser, jsonEncode(user.toMap()));
      await _prefs.setBool(AppConstants.kIsLoggedIn, true);
    } catch (_) {
      throw CacheException('Could not save session');
    }
  }

  @override
  UserModel? getCachedUser() {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return UserModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_kUser);
    await _prefs.setBool(AppConstants.kIsLoggedIn, false);
  }
}
