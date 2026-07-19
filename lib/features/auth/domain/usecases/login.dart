import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'sign_up.dart' show AuthParams;

class Login implements UseCase<UserEntity, AuthParams> {
  const Login(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(AuthParams params) =>
      _repository.login(email: params.email, password: params.password);
}
