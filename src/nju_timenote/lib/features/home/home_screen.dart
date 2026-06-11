import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_shell.dart';
import '../timetable/models/course.dart';
import '../todos/domain/todo.dart';
import '../todos/presentation/screens/todos_screen.dart';
import '../todos/presentation/widgets/todo_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesControllerProvider).value ?? [];
    final todosState = ref.watch(todosControllerProvider).value;
    final todos = todosState?.todos ?? [];
    final nextCourse = courses.isNotEmpty ? courses.first : null;
    final nextTodo = todos.where((todo) => !todo.isDone).firstOrNull;
    final deadlineTodos = todosState?.deadlineTodos ?? const <TodoItem>[];

    return AppGradientScaffold(
      child: Stack(
        children: [
          const _HomeTopGlow(),
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const SizedBox(height: 16),
              _HomeHeader(
                onSettings: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
              const SizedBox(height: 32),
              _NextCourseCard(course: nextCourse),
              const SizedBox(height: 24),
              _NextTodoCard(todo: nextTodo),
              const SizedBox(height: 24),
              _DdlCard(
                todos: deadlineTodos,
                onTap: () async {
                  await ref
                      .read(todosControllerProvider.notifier)
                      .setFilter(const TodoFilter(onlyDeadline: true));
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(AppRoutes.todos);
                  }
                },
              ),
              const SizedBox(height: 32),
              TodoBottomInputBar(
                onQuickPick: () =>
                    Navigator.of(context).pushNamed(AppRoutes.nextAction),
                onInput: () => showCreateTodoSheet(context, ref),
                onSearch: () =>
                    Navigator.of(context).pushNamed(AppRoutes.todoSearch),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeTopGlow extends StatelessWidget {
  const _HomeTopGlow();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 225,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE7F2FF),
              Color(0xFFF1ECFF),
              Color(0xFFFFF4FA),
              Color(0x00FFFFFF),
            ],
            stops: [0, 0.42, 0.72, 1],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '欢迎回来 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  '今天也要加油呀！💙',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('home-settings-button'),
            tooltip: '设置',
            onPressed: onSettings,
            icon: const Icon(
              Icons.settings_outlined,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextCourseCard extends StatelessWidget {
  const _NextCourseCard({required this.course});

  final Course? course;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.timetable),
      child: Row(
        children: [
          const CircleIcon(icon: Icons.school_outlined, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '下一节课',
                      style: TextStyle(color: AppColors.accent, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.control),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '进行中',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (course != null) ...[
                  Text(
                    course!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MutedMeta(
                        icon: Icons.location_on_outlined,
                        label: course!.location,
                      ),
                      _MutedMeta(
                        icon: Icons.access_time,
                        label: course!.periodRange.label,
                      ),
                    ],
                  ),
                ] else
                  Text(
                    '暂无课程，去添加吧',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.border),
        ],
      ),
    );
  }
}

class _NextTodoCard extends StatelessWidget {
  const _NextTodoCard({required this.todo});

  final TodoItem? todo;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.todos),
      child: Row(
        children: [
          const CircleIcon(icon: Icons.assignment_outlined, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '下一件事',
                  style: TextStyle(color: AppColors.accent, fontSize: 13),
                ),
                const SizedBox(height: 6),
                if (todo != null) ...[
                  Text(
                    todo!.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  _MutedMeta(
                    icon: Icons.access_time,
                    label: todo!.deadlineAt == null
                        ? '暂无截止时间'
                        : '截止：${formatDateTimeShort(todo!.deadlineAt!)}',
                  ),
                ] else
                  Text(
                    '暂无待办，去添加吧',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.border),
        ],
      ),
    );
  }
}

class _DdlCard extends StatelessWidget {
  const _DdlCard({required this.todos, required this.onTap});

  final List<TodoItem> todos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              const CircleIcon(icon: Icons.notifications_none, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'DDL 提醒',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${todos.length} 项进行中',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                '全部 >',
                style: TextStyle(color: AppColors.accent, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: Column(
              children: [for (final todo in todos.take(2)) _DdlRow(todo: todo)],
            ),
          ),
        ],
      ),
    );
  }
}

class _DdlRow extends StatelessWidget {
  const _DdlRow({required this.todo});

  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    final urgent =
        todo.deadlineAt != null &&
        todo.deadlineAt!.difference(DateTime.now()).inHours < 24;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: urgent ? AppColors.accent : const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todo.deadlineAt == null
                      ? '暂无截止时间'
                      : '${formatDateTimeShort(todo.deadlineAt!)} 截止',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: urgent ? const Color(0xFFFCE7F3) : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: Text(
              urgent ? '即将截止' : '1天后截止',
              style: TextStyle(
                fontSize: 10,
                color: urgent
                    ? const Color(0xFFDB2777)
                    : const Color(0xFFEA580C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedMeta extends StatelessWidget {
  const _MutedMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
