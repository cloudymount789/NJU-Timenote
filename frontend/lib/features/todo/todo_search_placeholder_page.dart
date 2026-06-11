import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_page.dart';

class TodoSearchPlaceholderPage extends StatelessWidget {
  const TodoSearchPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '搜索',
      message: '搜索框自动聚焦、历史和结果列表会在任务 4 完成。',
    );
  }
}
