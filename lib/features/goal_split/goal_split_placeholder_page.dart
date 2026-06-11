import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_page.dart';

class GoalSplitPlaceholderPage extends StatelessWidget {
  const GoalSplitPlaceholderPage({this.initialTitle, super.key});

  final String? initialTitle;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: '大目标拆分',
      message: initialTitle == null
          ? '三步拆分流程会在任务 4 完成。'
          : '已带入大目标名称：$initialTitle。三步拆分流程会在任务 4 完成。',
    );
  }
}
