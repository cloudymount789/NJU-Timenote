import 'package:flutter/material.dart';

import '../../core/widgets/create_todo_sheet.dart';
import '../../core/widgets/placeholder_page.dart';

class TodoListPlaceholderPage extends StatelessWidget {
  const TodoListPlaceholderPage({required this.onlyDeadline, super.key});

  final bool onlyDeadline;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: onlyDeadline ? '待办 · DDL' : '待办',
      message: onlyDeadline
          ? '已带 onlyDeadline=true 语义，筛选列表会在任务 3 完成。'
          : '待办列表、筛选、详情和批量操作会在任务 3 完成。',
      extra: TextButton.icon(
        onPressed: () => showCreateTodoSheet(context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('打开创建待办浮层'),
      ),
    );
  }
}
