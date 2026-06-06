import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const TimenoteApp());
    await tester.pumpAndSettle();
  }

  testWidgets('home starts and navigates to settings', (tester) async {
    await pumpApp(tester);

    expect(find.text('欢迎回来 👋'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('课表与作息'), findsOneWidget);
  });

  testWidgets('home navigates to timetable', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('下一节课'));
    await tester.pumpAndSettle();

    expect(find.text('我的课表'), findsOneWidget);
    expect(find.text('微积分 II'), findsOneWidget);
  });

  testWidgets('manual course creation refreshes timetable', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('下一节课'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timetable-add-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manual-course-option')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('course-name-field')), '软件工程');
    await tester.enterText(
      find.byKey(const Key('course-location-field')),
      '仙林 B406',
    );
    await tester.tap(find.byKey(const Key('submit-course-button')));
    await tester.pumpAndSettle();

    expect(find.text('我的课表'), findsOneWidget);
    expect(find.text('软件工程'), findsOneWidget);
  });

  testWidgets('long press deletes a course after confirmation', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('下一节课'));
    await tester.pumpAndSettle();
    expect(find.text('微积分 II'), findsOneWidget);

    await tester.longPress(find.text('微积分 II'));
    await tester.pumpAndSettle();
    expect(find.text('是否确定删除课程？'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-delete-course')));
    await tester.pumpAndSettle();

    expect(find.text('微积分 II'), findsNothing);
  });

  testWidgets('screenshot import adds mock courses', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('下一节课'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timetable-add-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('screenshot-course-option')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-screenshot-import')));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('我的课表'), findsOneWidget);
    expect(find.text('软件工程'), findsOneWidget);
  });

  testWidgets('placeholder todo routes are reachable', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('下一件事').first);
    await tester.pumpAndSettle();

    expect(find.text('待办'), findsAtLeastNWidgets(1));
    expect(find.textContaining('后续版本'), findsOneWidget);
  });
}
