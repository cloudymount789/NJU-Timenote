import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/widgets/placeholder_page.dart';

class SchedulePlaceholderPage extends StatelessWidget {
  const SchedulePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: '课表',
      message: '课表网格、手动添加和截图添加会在任务 2 完成。',
      extra: FilledButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scheduleAdd),
        icon: const Icon(Icons.add),
        label: const Text('添加课表入口'),
      ),
    );
  }
}
