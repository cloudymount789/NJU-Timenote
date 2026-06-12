import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_bottom_input_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/create_todo_sheet.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/course.dart';
import '../../data/models/todo.dart';
import '../../data/repositories/app_repositories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<_HomeData>? _future;
  AppRepositories? _repositories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repositories = AppScope.repositoriesOf(context);
    if (_repositories == repositories) {
      return;
    }
    _repositories?.changes.removeListener(_handleDataChanged);
    _repositories = repositories;
    repositories.changes.addListener(_handleDataChanged);
    _future = _load(repositories);
  }

  @override
  void dispose() {
    _repositories?.changes.removeListener(_handleDataChanged);
    super.dispose();
  }

  void _handleDataChanged() {
    if (mounted) {
      setState(() {
        _future = _load(_repositories!);
      });
    }
  }

  Future<_HomeData> _load(AppRepositories repositories) async {
    final results = await Future.wait<Object?>([
      repositories.courses.getNextCourse(),
      repositories.todos.getNextTodo(),
      repositories.todos.getTodos(
        const TodoFilter(
          kinds: [TodoKind.deadline],
          statuses: [TodoStatus.open],
        ),
      ),
    ]);
    final deadlines =
        (results[2]! as List<TodoItem>)
            .where((todo) => todo.deadlineAt != null)
            .toList()
          ..sort((a, b) => a.deadlineAt!.compareTo(b.deadlineAt!));
    return _HomeData(
      nextCourse: results[0] as Course?,
      nextTodo: results[1] as TodoItem?,
      nextDeadline: deadlines.firstOrNull,
    );
  }

  Future<void> _refresh() async {
    final future = _load(_repositories!);
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final compact = height < 720;
          final veryCompact = height < 650;
          final horizontalPadding = veryCompact
              ? 14.0
              : compact
              ? 18.0
              : 20.0;
          final topPadding = veryCompact
              ? 8.0
              : compact
              ? 18.0
              : 48.0;
          final headerGap = veryCompact
              ? 12.0
              : compact
              ? 16.0
              : 24.0;
          final cardGap = veryCompact
              ? 8.0
              : compact
              ? 12.0
              : 14.0;
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          final bottomGap = bottomInset > 0
              ? 12.0
              : compact
              ? 18.0
              : 24.0;
          final bottomBarHeight = compact ? 60.0 : 72.0;
          final bottomReserve = bottomBarHeight + bottomGap + 14;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                bottom: bottomReserve,
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      8,
                    ),
                    child: FutureBuilder<_HomeData>(
                      future: _future,
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState != ConnectionState.done;
                        final data = snapshot.data;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppHeader(
                              title: '今天也要加油啊 ♥',
                              subtitle: 'NJU Timenote',
                              trailing: AppIconButton(
                                icon: Icons.settings_outlined,
                                tooltip: '设置',
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.settings),
                                size: 32,
                              ),
                            ),
                            SizedBox(height: headerGap),
                            _HomeNavCard(
                              icon: Icons.school_outlined,
                              title: '下一节课',
                              emptyTitle: data?.nextCourse == null
                                  ? '暂时没有下一节课'
                                  : data!.nextCourse!.name,
                              emptyMessage: data?.nextCourse == null
                                  ? '添加课表后，这里会显示即将开始的课程。'
                                  : _courseMessage(data!.nextCourse!),
                              compact: compact,
                              isLoading: loading,
                              hasError: snapshot.hasError,
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.schedule),
                            ),
                            SizedBox(height: cardGap),
                            _HomeNavCard(
                              icon: Icons.check_circle_outline,
                              title: '下一件事',
                              emptyTitle: data?.nextTodo == null
                                  ? '还没有待办'
                                  : data!.nextTodo!.title,
                              emptyMessage: data?.nextTodo == null
                                  ? '记录待办后，这里会提示下一件值得处理的事。'
                                  : _todoMessage(data!.nextTodo!),
                              compact: compact,
                              isLoading: loading,
                              hasError: snapshot.hasError,
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.todos),
                            ),
                            SizedBox(height: cardGap),
                            _DeadlineCard(
                              deadline: data?.nextDeadline,
                              compact: compact,
                              isLoading: loading,
                              hasError: snapshot.hasError,
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.todos),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: bottomGap + bottomInset,
                child: AppBottomInputBar(
                  compact: compact,
                  onInputTap: () => showCreateTodoSheet(context),
                  onSearchTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.todoSearch),
                  onQuickPickTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.nextThing),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    required this.icon,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.compact,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final bool compact;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 16 : 20),
      shadowPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          Container(
            width: compact ? 46 : 52,
            height: compact ? 46 : 52,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isLoading
                ? const LoadingState()
                : hasError
                ? const ErrorState(message: '稍后再试。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        emptyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: compact ? 1 : 2),
                      Text(
                        emptyMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.subtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: AppColors.line, size: 18),
        ],
      ),
    );
  }
}

class _CompactDeadlineEmptyState extends StatelessWidget {
  const _CompactDeadlineEmptyState({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hourglass_empty_outlined,
          size: compact ? 28 : 32,
          color: AppColors.subtle,
        ),
        SizedBox(height: compact ? 6 : 8),
        const Text(
          '暂无临近截止事项',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: compact ? 3 : 5),
        const Text(
          '有 DDL 的待办会集中显示在这里。',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.subtle, fontSize: 13),
        ),
      ],
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({
    required this.deadline,
    required this.compact,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
  });

  final TodoItem? deadline;
  final bool compact;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      shadowPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'DDL 提醒',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.line, size: 18),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const LoadingState()
                : hasError
                ? const ErrorState(message: '无法读取截止提醒。')
                : deadline == null
                ? _CompactDeadlineEmptyState(compact: compact)
                : _CompactDeadlineState(todo: deadline!, compact: compact),
          ),
        ],
      ),
    );
  }
}

class _CompactDeadlineState extends StatelessWidget {
  const _CompactDeadlineState({required this.todo, required this.compact});

  final TodoItem todo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: compact ? 28 : 32,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                todo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: compact ? 3 : 5),
              Text(
                'DDL: ${_dateTimeText(todo.deadlineAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.nextCourse,
    required this.nextTodo,
    required this.nextDeadline,
  });

  final Course? nextCourse;
  final TodoItem? nextTodo;
  final TodoItem? nextDeadline;
}

String _courseMessage(Course course) {
  return '周${_weekdayName(course.dayOfWeek)} 第 ${course.startPeriod}-${course.endPeriod} 节 · ${course.location}';
}

String _todoMessage(TodoItem todo) {
  return switch (todo.kind) {
    TodoKind.duration => '持续: ${_dateTimeText(todo.startAt)}',
    TodoKind.deadline => 'DDL: ${_dateTimeText(todo.deadlineAt)}',
    TodoKind.normal => todo.tags.isEmpty ? '普通待办' : todo.tags.join(' · '),
  };
}

String _dateTimeText(DateTime? value) {
  if (value == null) {
    return '未设置';
  }
  return '${value.month}.${value.day} ${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _weekdayName(int dayOfWeek) {
  return const ['一', '二', '三', '四', '五', '六', '日'][dayOfWeek - 1];
}
