import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp implements UseCase<UserEntity, AuthParams> {
  const SignUp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(AuthParams params) =>
      _repository.signUp(email: params.email, password: params.password);
}

/// Shared params for credential-based auth use cases.
class AuthParams extends Equatable {
  const AuthParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
