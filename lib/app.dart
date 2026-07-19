import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

class TeamWorkspaceApp extends StatefulWidget {
  const TeamWorkspaceApp({super.key, this.flavor = 'main'});

  final String flavor;

  @override
  State<TeamWorkspaceApp> createState() => _TeamWorkspaceAppState();
}

class _TeamWorkspaceAppState extends State<TeamWorkspaceApp> {
  late final AuthBloc _authBloc;
  late final TaskBloc _taskBloc;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _taskBloc = sl<TaskBloc>();
    _router = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _taskBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: BlocProvider<TaskBloc>.value(
        value: _taskBloc,
        child: MaterialApp.router(
          title: '${AppConstants.appName} (${widget.flavor.toUpperCase()})',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: _router.router,
        ),
      ),
    );
  }
}
