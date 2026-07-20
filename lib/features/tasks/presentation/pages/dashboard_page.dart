import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

/// Tasks dashboard: paginated, infinite-scroll list with pull-to-refresh and
/// graceful loading / empty / error states.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<TaskBloc>()..add(const TasksFetched()),
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

  Future<void> _openCreate() async {
    final created = await AppNavigator.push<TaskEntity?>(context, '/tasks/new');
    if (created != null && mounted) {
      context.read<TaskBloc>().add(TaskInserted(created));
    }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // First load / hard failure states own the whole screen.
          if (state.status == TaskListStatus.initial ||
              state.status == TaskListStatus.loading) {
            return const LoadingView(message: 'Loading tasks…');
          }
          if (state.status == TaskListStatus.failure && state.tasks.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Could not load tasks.',
              onRetry: () => context.read<TaskBloc>().add(const TasksFetched()),
            );
          }
          if (state.tasks.isEmpty) {
            return const EmptyView(message: 'No tasks yet');
          }

          // Loaded: search/filter bar + the filtered list.
          final filtered = state.filteredTasks;
          return Column(
            children: [
              const TaskFilterBar(),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyView(
                        message: 'No tasks match your search / filters',
                        icon: Icons.search_off,
                      )
                    : _TaskList(
                        scrollController: _scrollController,
                        tasks: filtered,
                        showLoader:
                            !state.hasReachedMax && !state.hasActiveFilters,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.scrollController,
    required this.tasks,
    required this.showLoader,
  });

  final ScrollController scrollController;
  final List<TaskEntity> tasks;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(const TasksRefreshed());
      },
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length + (showLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= tasks.length) {
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
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => AppNavigator.push(context, '/tasks/${task.id}'),
          );
        },
      ),
    );
  }
}
