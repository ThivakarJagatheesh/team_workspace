import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/error/failures.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/usecases/get_current_user.dart';
import 'package:team_workspace/features/auth/domain/usecases/login.dart';
import 'package:team_workspace/features/auth/domain/usecases/logout.dart';
import 'package:team_workspace/features/auth/domain/usecases/sign_up.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';

import '../../helpers/fixtures.dart';

class MockSignUp extends Mock implements SignUp {}

class MockLogin extends Mock implements Login {}

class MockLogout extends Mock implements Logout {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late MockSignUp signUp;
  late MockLogin login;
  late MockLogout logout;
  late MockGetCurrentUser getCurrentUser;

  setUpAll(() {
    registerFallbackValue(const AuthParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    signUp = MockSignUp();
    login = MockLogin();
    logout = MockLogout();
    getCurrentUser = MockGetCurrentUser();
  });

  AuthBloc build() => AuthBloc(
        signUp: signUp,
        login: login,
        logout: logout,
        getCurrentUser: getCurrentUser,
      );

  group('AuthBloc login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when login succeeds',
      build: () {
        when(() => login(any()))
            .thenAnswer((_) async => const Right<Failure, UserEntity>(tUser));
        return build();
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@example.com', password: 'secret1'),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when login fails',
      build: () {
        when(() => login(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Incorrect email or password.')),
        );
        return build();
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'x@y.com', password: 'bad'),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure('Incorrect email or password.'),
      ],
    );
  });

  group('AuthBloc check', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when a session exists',
      build: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Right<Failure, UserEntity?>(tUser));
        return build();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState.authenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no session',
      build: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Right<Failure, UserEntity?>(null));
        return build();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });
}
