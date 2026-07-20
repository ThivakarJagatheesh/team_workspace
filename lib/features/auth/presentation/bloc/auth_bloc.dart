import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns authentication state for the whole app. Kept thin: each event delegates
/// to a single use case and maps the `Either<Failure, _>` result to a state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignUp signUp,
    required Login login,
    required Logout logout,
    required GetCurrentUser getCurrentUser,
  })  : _signUp = signUp,
        _login = login,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  final SignUp _signUp;
  final Login _login;
  final Logout _logout;
  final GetCurrentUser _getCurrentUser;

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit,) async {
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) => emit(
        user != null
            ? AuthState.authenticated(user)
            : const AuthState.unauthenticated(),
      ),
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signUp(
      AuthParams(email: event.email, password: event.password),
    );
    result.fold(
      (f) => emit(AuthState.failure(f.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _login(
      AuthParams(email: event.email, password: event.password),
    );
    result.fold(
      (f) => emit(AuthState.failure(f.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}
