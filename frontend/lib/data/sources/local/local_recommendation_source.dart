import '../../models/recommendation.dart';
import '../../models/todo.dart';
import 'local_todo_source.dart';

class LocalRecommendationSource {
  const LocalRecommendationSource(this._todos);

  final LocalTodoSource _todos;

  Future<List<TodoRecommendation>> getRecommendations(
    RecommendationInput input,
  ) async {
    final openTodos = await _todos.getTodos(
      const TodoFilter(statuses: [TodoStatus.open]),
    );
    final recommendations = <TodoRecommendation>[];
    if (openTodos.isNotEmpty) {
      final urgent = openTodos.first;
      recommendations.add(
        TodoRecommendation(
          section: '不得不做',
          title: urgent.title,
          reason: '它在当前未完成待办中时间最靠前。',
          todoId: urgent.id,
        ),
      );
      final suitable = _pickSuitable(openTodos, input);
      if (suitable.id != urgent.id) {
        recommendations.add(
          TodoRecommendation(
            section: '适合当前状态',
            title: suitable.title,
            reason: _reasonFor(input),
            todoId: suitable.id,
          ),
        );
      }
    }
    recommendations.add(
      TodoRecommendation(
        section: '其他可以做的事',
        title: input.willingness < 35 ? '休息十分钟' : '整理一下下一步',
        reason: input.willingness < 35 ? '先把状态找回来，再处理真正的待办。' : '给接下来的事情清一个小入口。',
        canAdd: true,
      ),
    );
    return recommendations;
  }

  TodoItem _pickSuitable(List<TodoItem> todos, RecommendationInput input) {
    if (input.anxiety >= 70) {
      return todos.firstWhere(
        (todo) => todo.priority >= 4,
        orElse: () => todos.first,
      );
    }
    if (input.willingness <= 40) {
      return todos.firstWhere(
        (todo) => todo.kind == TodoKind.normal,
        orElse: () => todos.last,
      );
    }
    return todos.first;
  }

  String _reasonFor(RecommendationInput input) {
    if (input.anxiety >= 70) {
      return '焦虑偏高，优先处理更重要的事。';
    }
    if (input.willingness <= 40) {
      return '启动意愿偏低，普通待办更适合作为热身。';
    }
    return '它和你当前状态比较匹配。';
  }
}
