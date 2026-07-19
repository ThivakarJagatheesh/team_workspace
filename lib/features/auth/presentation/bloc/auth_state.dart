part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? message;

  const AuthState.unknown() : this();
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.authenticated(UserEntity user)
      : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.failure(String message)
      : this(status: AuthStatus.failure, message: message);

  @override
  List<Object?> get props => [status, user, message];
}
