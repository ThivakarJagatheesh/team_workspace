import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Auth contract the domain depends on. Implemented in the data layer by
/// wrapping Firebase — domain stays framework-free.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  /// Currently signed-in user (from Firebase / cache), or null if none.
  /// Used on startup to restore the session.
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
