import '../../models/goal_split.dart';
import '../../models/todo.dart';
import 'local_todo_source.dart';

class LocalGoalSplitSource {
  const LocalGoalSplitSource(this._todos);

  final LocalTodoSource _todos;

  Future<void> createFromGoalSplit(GoalSplitDraft draft) async {
    final goalTag = goalSplitTagForTitle(draft.title);
    if (draft.title.trim().isEmpty || draft.subtasks.isEmpty) {
      throw ArgumentError('大目标和至少一个小目标不能为空');
    }
    for (final subtask in draft.subtasks) {
      if (subtask.title.trim().isEmpty) {
        throw ArgumentError('小目标名称不能为空');
      }
      if (_dateOnly(
        subtask.plannedDate,
      ).isAfter(_dateOnly(draft.finalDeadline))) {
        throw ArgumentError('小目标日期不能晚于最终 DDL');
      }
    }
    for (final subtask in draft.subtasks) {
      await _todos.createTodo(
        TodoDraft(
          title: subtask.title,
          content: draft.note,
          kind: TodoKind.deadline,
          deadlineAt: DateTime(
            subtask.plannedDate.year,
            subtask.plannedDate.month,
            subtask.plannedDate.day,
            23,
            59,
          ),
          priority: 4,
          tags: [goalTag],
        ),
      );
    }
  }
}

String goalSplitTagForTitle(String title) {
  final normalized = title.trim().replaceAll(RegExp(r'\s+'), ' ');
  final base = normalized.isEmpty ? '大目标' : normalized;
  return base.length <= 12 ? base : '${base.substring(0, 12)}...';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
