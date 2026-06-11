import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/app/app.dart';

void main() {
  testWidgets('starts on home and opens settings', (tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();

    expect(find.text('今天也要加油啊'), findsOneWidget);
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

    await tester.scrollUntilVisible(find.text('智能一句话添加待办...'), 120);
    await tester.tap(find.text('智能一句话添加待办...'));
    await tester.pumpAndSettle();

    expect(find.text('创建待办'), findsOneWidget);
    expect(find.text('手动创建待办'), findsOneWidget);
  });

  testWidgets('router exposes deadline todo semantic route', (tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('DDL 提醒'));
    await tester.pumpAndSettle();

    expect(find.text('DDL 提醒'), findsOneWidget);
    expect(find.text('暂无待办'), findsOneWidget);
  });
}
