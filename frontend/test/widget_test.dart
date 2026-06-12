import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/app/app.dart';
import 'package:nju_timenote/app/router.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/repositories/app_repositories.dart';
import 'package:nju_timenote/data/repositories/repository_factory.dart';
import 'package:nju_timenote/features/todo/todo_detail_page.dart';
import 'package:nju_timenote/features/todo/todo_list_page.dart';

void main() {
  testWidgets('starts on home and opens settings', (tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('今天也要加油啊'), findsOneWidget);
    expect(find.text('下一节课'), findsOneWidget);
    expect(find.text('下一件事'), findsOneWidget);
    expect(find.text('DDL 提醒'), findsOneWidget);

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('课表与作息'), findsOneWidget);
    expect(find.text('数据与分享'), findsOneWidget);
  });

  testWidgets('home can open create todo sheet', (tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('智能一句话添加待办...'));
    await tester.pumpAndSettle();

    expect(find.text('创建待办'), findsOneWidget);
    expect(find.text('手动创建待办'), findsOneWidget);
  });

  testWidgets('deadline card opens the default todo list', (tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('DDL 提醒'));
    await tester.pumpAndSettle();

    expect(find.text('待办'), findsOneWidget);
    expect(find.text('暂无待办'), findsOneWidget);
  });

  testWidgets('creating a todo from list detail refreshes visible list', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加待办'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '标题'), '新待办');
    await tester.ensureVisible(find.text('保存'));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('新待办'), findsOneWidget);
  });

  testWidgets('todo detail tag row opens tag selection with or without tags', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: const TodoDetailPage(isCreate: true),
      ),
    );
    await tester.pumpAndSettle();

    final tagPicker = find.byKey(const ValueKey('todo-tag-picker'));
    await tester.ensureVisible(tagPicker);
    await tester.tap(tagPicker);
    await tester.pumpAndSettle();

    expect(find.text('选择 Tag'), findsOneWidget);
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    final created = await repositories.todos.createTodo(
      const TodoDraft(title: '带 tag', tags: ['作业']),
    );
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: TodoDetailPage(isCreate: false, todoId: created.id),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(tagPicker);
    await tester.tap(tagPicker);
    await tester.pumpAndSettle();

    expect(find.text('选择 Tag'), findsOneWidget);
  });
}

class _ScopedTestApp extends StatelessWidget {
  const _ScopedTestApp({required this.repositories, required this.home});

  final AppRepositories repositories;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repositories: repositories,
      clock: const AppClock(),
      child: MaterialApp(
        home: home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
