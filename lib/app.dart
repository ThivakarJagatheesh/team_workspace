import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
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
  var _isDarkMode = false;

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

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? AppTheme.dark : AppTheme.light;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<TaskBloc>.value(value: _taskBloc),
      ],
      child: ThemeModeController(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
        child: MaterialApp.router(
          title: '${AppConstants.appName} (${widget.flavor.toUpperCase()})',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: AppTheme.dark,
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router.router,
        ),
      ),
    );
  }
}
