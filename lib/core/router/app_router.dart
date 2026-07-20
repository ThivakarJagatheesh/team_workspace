import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../../features/tasks/presentation/cubit/create_task_cubit.dart';
import '../../features/tasks/presentation/pages/create_task_page.dart';
import '../../features/tasks/presentation/pages/dashboard_page.dart';
import '../../features/tasks/presentation/pages/edit_task_page.dart';
import '../../features/tasks/presentation/pages/task_details_page.dart';
import '../di/injection.dart';

class AppRouter {
  AppRouter({required this.authBloc}) {
    authBloc.stream.listen((_) => router.refresh());
  }

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authStatus = authBloc.state.status;
      return resolveRedirect(authStatus, state.matchedLocation);
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/tasks/:taskId',
        builder: (context, state) {
          final taskId = int.tryParse(state.pathParameters['taskId'] ?? '');
          if (taskId == null) {
            return const Scaffold(body: Center(child: Text('Invalid task id')));
          }
          return TaskDetailsPage(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/tasks/:taskId/edit',
        builder: (context, state) {
          final taskId = int.tryParse(state.pathParameters['taskId'] ?? '');
          final task = state.extra;
          if (taskId == null || task is! TaskEntity) {
            return const Scaffold(body: Center(child: Text('Invalid task')));
          }
          return EditTaskPage(task: task);
        },
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<CreateTaskCubit>(),
            child: const CreateTaskPage(),
          );
        },
      ),
    ],
  );

  static String? resolveRedirect(AuthStatus status, String location) {
    final isAuthRoute = location == '/login' || location == '/sign-up';

    if (status == AuthStatus.unauthenticated && !isAuthRoute) {
      return '/login';
    }

    if (status == AuthStatus.authenticated && isAuthRoute) {
      return '/';
    }

    return null;
  }
}
