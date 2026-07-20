import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class Login implements UseCase<UserEntity, AuthParams> {
  const Login(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(AuthParams params) =>
      _repository.login(email: params.email, password: params.password);
}
