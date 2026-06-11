import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_input_bar.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/create_todo_sheet.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/course.dart';
import '../../data/models/todo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repositories = AppScope.repositoriesOf(context);

    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          28,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      AppHeader(
                        title: '今天也要加油啊',
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
                      const SizedBox(height: 32),
                      FutureBuilder<Course?>(
                        future: repositories.courses.getNextCourse(),
                        builder: (context, snapshot) {
                          return _HomeNavCard(
                            icon: Icons.school_outlined,
                            title: '下一节课',
                            emptyTitle: '暂时没有下一节课',
                            emptyMessage: '添加课表后，这里会显示即将开始的课程。',
                            isLoading:
                                snapshot.connectionState !=
                                ConnectionState.done,
                            hasError: snapshot.hasError,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.schedule),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      FutureBuilder<TodoItem?>(
                        future: repositories.todos.getNextTodo(),
                        builder: (context, snapshot) {
                          return _HomeNavCard(
                            icon: Icons.check_circle_outline,
                            title: '下一件事',
                            emptyTitle: '还没有待办',
                            emptyMessage: '记录待办后，这里会提示下一件值得处理的事。',
                            isLoading:
                                snapshot.connectionState !=
                                ConnectionState.done,
                            hasError: snapshot.hasError,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.todos),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      FutureBuilder<List<TodoItem>>(
                        future: repositories.todos.getTodos(
                          const TodoFilter(onlyDeadline: true),
                        ),
                        builder: (context, snapshot) {
                          return AppCard(
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.todos,
                              arguments: const TodoListRouteArgs(
                                onlyDeadline: true,
                              ),
                            ),
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
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.line,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      snapshot.connectionState !=
                                          ConnectionState.done
                                      ? const LoadingState()
                                      : snapshot.hasError
                                      ? const ErrorState(message: '无法读取截止提醒。')
                                      : const EmptyState(
                                          title: '暂无临近截止事项',
                                          message: '有 DDL 的待办会集中显示在这里。',
                                          icon: Icons.hourglass_empty_outlined,
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      AppBottomInputBar(
                        onInputTap: () => showCreateTodoSheet(context),
                        onSearchTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.todoSearch),
                        onQuickPickTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.nextThing),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
    required this.isLoading,
    required this.hasError,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 2),
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
