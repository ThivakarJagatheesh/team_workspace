import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import 'task_details_page.dart';

/// Tasks dashboard: paginated, infinite-scroll list with pull-to-refresh and
/// graceful loading / empty / error states.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(const TasksFetched()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) context.read<TaskBloc>().add(const TasksFetched());
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final max = _scrollController.position.maxScrollExtent;
    return _scrollController.offset >= max * 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          switch (state.status) {
            case TaskListStatus.initial:
            case TaskListStatus.loading:
              return const LoadingView(message: 'Loading tasks…');

            case TaskListStatus.failure:
              if (state.tasks.isEmpty) {
                return ErrorView(
                  message: state.errorMessage ?? 'Could not load tasks.',
                  onRetry: () =>
                      context.read<TaskBloc>().add(const TasksFetched()),
                );
              }
              // Failure while paginating: keep the list, show a snackbar once.
              return _TaskList(
                scrollController: _scrollController,
                state: state,
              );

            case TaskListStatus.success:
              if (state.tasks.isEmpty) {
                return const EmptyView(message: 'No tasks yet');
              }
              return _TaskList(
                scrollController: _scrollController,
                state: state,
              );
          }
        },
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.scrollController, required this.state});

  final ScrollController scrollController;
  final TaskState state;

  @override
  Widget build(BuildContext context) {
    final showLoader = !state.hasReachedMax;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(const TasksRefreshed());
      },
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.tasks.length + (showLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.tasks.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final task = state.tasks[index];
          return TaskCard(
            task: task,
            onTap: () => Navigator.of(context)
                .push(TaskDetailsPage.route(context, task.id)),
          );
        },
      ),
    );
  }
}
