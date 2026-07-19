import 'package:flutter_test/flutter_test.dart';
import 'package:team_workspace/core/router/app_router.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  group('AppRouter.redirect', () {
    test('redirects unauthenticated users to login', () {
      expect(
        AppRouter.resolveRedirect(AuthStatus.unauthenticated, '/'),
        '/login',
      );
    });

    test('allows authenticated users to visit the dashboard', () {
      expect(
        AppRouter.resolveRedirect(AuthStatus.authenticated, '/'),
        null,
      );
    });

    test('allows auth pages for unauthenticated visitors', () {
      expect(
        AppRouter.resolveRedirect(AuthStatus.unauthenticated, '/login'),
        null,
      );
      expect(
        AppRouter.resolveRedirect(AuthStatus.unauthenticated, '/sign-up'),
        null,
      );
    });
  });
}
