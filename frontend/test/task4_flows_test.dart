import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/data/models/goal_split.dart';
import 'package:nju_timenote/data/models/recommendation.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/repositories/repository_factory.dart';
import 'package:nju_timenote/data/sources/local/local_goal_split_source.dart';
import 'package:nju_timenote/data/sources/local/local_recommendation_source.dart';
import 'package:nju_timenote/data/sources/local/local_tag_source.dart';
import 'package:nju_timenote/data/sources/local/local_todo_source.dart';

void main() {
  test(
    'quick create stores the whole sentence as a normal todo title',
    () async {
      final repos = RepositoryFactory.local();

      final todo = await repos.quickTodos.createFromSentence('整理本周复习计划');

      expect(todo.title, '整理本周复习计划');
      expect(todo.kind, TodoKind.normal);
      expect(await repos.todos.getTodos(), hasLength(1));
    },
  );

  test(
    'search matches title content location and tags case-insensitively',
    () async {
      final tags = LocalTagSource();
      final todos = LocalTodoSource(tags);
      await todos.createTodo(
        const TodoDraft(
          title: 'Read Paper',
          content: 'Graph neural network',
          location: 'Library',
          tags: ['Research'],
        ),
      );

      expect(await todos.searchTodos('paper'), hasLength(1));
      expect(await todos.searchTodos('GRAPH'), hasLength(1));
      expect(await todos.searchTodos('library'), hasLength(1));
      expect(await todos.searchTodos('research'), hasLength(1));
    },
  );

  test(
    'recommendation without todos returns only local addable suggestion',
    () async {
      final todos = LocalTodoSource(LocalTagSource());
      final recommendations = await LocalRecommendationSource(todos)
          .getRecommendations(
            const RecommendationInput(mood: 50, willingness: 20, anxiety: 30),
          );

      expect(recommendations.where((item) => item.todoId != null), isEmpty);
      expect(recommendations.single.canAdd, isTrue);
    },
  );

  test(
    'goal split validates subtask date and generates deadline todos',
    () async {
      final todos = LocalTodoSource(LocalTagSource());
      final source = LocalGoalSplitSource(todos);
      final finalDeadline = DateTime(2026, 6, 30);

      expect(
        source.createFromGoalSplit(
          GoalSplitDraft(
            title: '完成项目',
            note: '',
            finalDeadline: finalDeadline,
            subtasks: [
              GoalSubtaskDraft(
                title: '过晚任务',
                plannedDate: DateTime(2026, 7, 1),
              ),
            ],
          ),
        ),
        throwsArgumentError,
      );
      expect(await todos.getTodos(), isEmpty);

      await source.createFromGoalSplit(
        GoalSplitDraft(
          title: '完成项目',
          note: '阶段计划',
          finalDeadline: finalDeadline,
          subtasks: [
            GoalSubtaskDraft(title: '准备材料', plannedDate: DateTime(2026, 6, 20)),
            GoalSubtaskDraft(title: '完成初稿', plannedDate: DateTime(2026, 6, 28)),
          ],
        ),
      );

      final created = await todos.getTodos();
      expect(created, hasLength(2));
      expect(created.every((todo) => todo.kind == TodoKind.deadline), isTrue);
      expect(created.every((todo) => todo.priority == 4), isTrue);
      expect(created.every((todo) => todo.tags.contains('学习')), isTrue);
      expect(created.first.deadlineAt?.hour, 23);
      expect(created.first.deadlineAt?.minute, 59);
    },
  );
}
