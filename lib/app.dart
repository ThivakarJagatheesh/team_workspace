import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Theme + (later) router are wired here. For now it shows a
/// placeholder home confirming the scaffold is ready; feature routes are added
/// during stage-by-stage development.
class TeamWorkspaceApp extends StatelessWidget {
  const TeamWorkspaceApp({super.key, this.flavor = 'main'});

  final String flavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} (${flavor.toUpperCase()})',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _SetupHomePage(flavor: flavor),
    );
  }
}

class _SetupHomePage extends StatelessWidget {
  const _SetupHomePage({required this.flavor});

  final String flavor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspaces_outline, size: 64),
              const SizedBox(height: 16),
              Text('Project scaffold ready', style: text.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Clean Architecture · BLoC · GetIt · Dio · Firebase Auth\n'
                'Features are wired in stage by stage.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Flavor: ${flavor.toUpperCase()}',
                style: text.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
