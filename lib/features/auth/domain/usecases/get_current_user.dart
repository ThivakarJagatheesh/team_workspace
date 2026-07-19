import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Restores the session on startup. Returns null when nobody is signed in.
class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
