import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/user_entity.dart';

/// Data-layer representation of a user. Bridges Firebase + local cache and the
/// domain [UserEntity].
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
  });

  /// Build from a Firebase user.
  factory UserModel.fromFirebase(fb.User user) => UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );

  /// Build from cached JSON (SharedPreferences).
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };
}
