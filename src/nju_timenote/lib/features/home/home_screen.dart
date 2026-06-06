import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_shell.dart';
import '../../state/timenote_state.dart';
import '../timetable/models/course.dart';
import '../todos/models/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TimenoteScope.of(context);
    final nextCourse = state.courses.isNotEmpty ? state.courses.first : null;
    final nextTodo = state.todos.isNotEmpty ? state.todos.first : null;

    return AppGradientScaffold(
      child: Stack(
        children: [
          const _HomeTopGlow(),
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const StatusHeader(),
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
              _DdlCard(todos: state.deadlineTodos),
              const SizedBox(height: 32),
              _HomeInputBar(
                onQuickPick: () =>
                    Navigator.of(context).pushNamed(AppRoutes.nextAction),
                onInput: () => _showQuickInputSheet(context),
                onSearch: () =>
                    Navigator.of(context).pushNamed(AppRoutes.todoSearch),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickInputSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'AI 智能添加待办将在后续版本开放',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
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
                        borderRadius: BorderRadius.circular(12),
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
                Text(
                  course?.name ?? '高等数学 (第3-4节)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MutedMeta(
                      icon: Icons.location_on_outlined,
                      label: course?.location ?? '教学楼 A201',
                    ),
                    _MutedMeta(
                      icon: Icons.access_time,
                      label: course?.periodRange.label ?? '14:00 – 15:50',
                    ),
                  ],
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
                Text(
                  todo?.title ?? '完成数据结构实验报告',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                _MutedMeta(
                  icon: Icons.access_time,
                  label: todo?.dueAt == null ? '暂无截止时间' : '截止：今天 23:59',
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
  const _DdlCard({required this.todos});

  final List<TodoItem> todos;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.todos),
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
              borderRadius: BorderRadius.circular(8),
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
    final urgent = todo.id == 'todo-1';
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
                  urgent ? '今天 23:59 截止' : '明天 18:00 截止',
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
              borderRadius: BorderRadius.circular(7),
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

class _HomeInputBar extends StatelessWidget {
  const _HomeInputBar({
    required this.onQuickPick,
    required this.onInput,
    required this.onSearch,
  });

  final VoidCallback onQuickPick;
  final VoidCallback onInput;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5F8FF),
                  Color(0xFFF0F4FF),
                  Color(0xFFF5F0FF),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              tooltip: '快速挑选',
              onPressed: onQuickPick,
              icon: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Color(0xFF6B9FFF),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: onInput,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '智能一句话添加待办...',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          IconButton.filled(
            tooltip: '待办搜索',
            onPressed: onSearch,
            style: IconButton.styleFrom(
              fixedSize: const Size(40, 40),
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.search, size: 20, color: Colors.white),
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
