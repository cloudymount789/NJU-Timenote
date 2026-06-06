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
      bottomBar: BottomQuickInput(
        onSearch: () => Navigator.of(context).pushNamed(AppRoutes.todoSearch),
        onInput: () => _showQuickInputSheet(context),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        children: [
          StatusHeader(
            trailing: IconButton(
              key: const Key('home-settings-button'),
              tooltip: '设置',
              icon: const Icon(
                Icons.settings_outlined,
                size: 22,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
          ),
          const SizedBox(height: 8),
          Text('欢迎回来 👋', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          const Text(
            '今天也要加油呀！💙',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _NextCourseCard(course: nextCourse),
          const SizedBox(height: 14),
          _NextTodoCard(todo: nextTodo),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _MiniNoteCard(),
                    const SizedBox(height: 12),
                    _QuickPickCard(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _HeatMapCard()),
            ],
          ),
          const SizedBox(height: 14),
          _DdlCard(todos: state.deadlineTodos),
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

class _NextCourseCard extends StatelessWidget {
  const _NextCourseCard({required this.course});

  final Course? course;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.timetable),
      child: Row(
        children: [
          const CircleIcon(icon: Icons.school_outlined),
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
                      child: const Text(
                        '进行中',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  course?.name ?? '高等数学 (第3-4节)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course?.location ?? '教学楼 A201',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course?.periodRange.label ?? '14:00 – 15:50',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
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
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.todos),
      child: Row(
        children: [
          const CircleIcon(icon: Icons.assignment_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '下一件事',
                  style: TextStyle(color: AppColors.accent, fontSize: 13),
                ),
                const SizedBox(height: 7),
                Text(
                  todo?.title ?? '完成数据结构实验报告',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  todo?.dueAt == null ? '暂无截止时间' : '截止：今天 23:59',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MiniNoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.accent),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('随心记', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            tooltip: '新增随心记',
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _QuickPickCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.nextAction),
      padding: const EdgeInsets.all(14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accent),
              SizedBox(width: 8),
              Text('快速挑选', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '下一件事',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            '智能排序',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CircleIcon(icon: Icons.chevron_right, size: 30),
          ),
        ],
      ),
    );
  }
}

class _HeatMapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cells = List<int>.generate(35, (index) => (index * 7 + 3) % 5);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                color: AppColors.accent,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '本月热力图',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '5月',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '看看你的努力分布',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final opacity = 0.16 + cells[index] * 0.17;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
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
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.todos),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_none, color: AppColors.accent),
              const SizedBox(width: 10),
              const Text(
                'DDL 提醒',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '${todos.length} 项进行中',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              const Text(
                '全部 >',
                style: TextStyle(color: AppColors.accent, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final todo in todos.take(2)) _DdlRow(todo: todo),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: urgent ? AppColors.accent : const Color(0xFF16A34A),
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
                Text(
                  urgent ? '今天 23:59 截止' : '明天 18:00 截止',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: urgent ? const Color(0xFFFFE7F1) : const Color(0xFFFFEAD6),
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
