import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_page.dart';

class TodoDetailPlaceholderPage extends StatelessWidget {
  const TodoDetailPlaceholderPage({required this.isCreate, super.key});

  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: isCreate ? '新建待办' : '待办详情',
      message: '详情编辑、tag、重复设置和删除会在任务 3 完成。',
    );
  }
}
