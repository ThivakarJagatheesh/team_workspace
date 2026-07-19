import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implements the domain [AuthRepository]: talks to Firebase (remote) and mirrors
/// the session into local cache. Exceptions → [Failure]s.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  }) =>
      _authCall(() => remote.signUp(email: email, password: password));

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) =>
      _authCall(() => remote.login(email: email, password: password));

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remote.logout();
      await local.clear();
      return const Right(unit);
    } catch (_) {
      return const Left(AuthFailure('Could not log out.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // Firebase is the source of truth; fall back to the local cache offline.
    final fromFirebase = remote.currentUser();
    if (fromFirebase != null) {
      await local.cacheUser(fromFirebase);
      return Right(fromFirebase);
    }
    return Right(local.getCachedUser());
  }

  /// Shared wrapper for sign-up/login: run the remote call, cache the user,
  /// map exceptions to failures.
  Future<Either<Failure, UserEntity>> _authCall(
    Future<UserModel> Function() call,
  ) async {
    try {
      final user = await call();
      await local.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure());
    }
  }
}
