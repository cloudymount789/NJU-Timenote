import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_page.dart';

class AddSchedulePlaceholderPage extends StatelessWidget {
  const AddSchedulePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '添加课表',
      message: '这里会承载手动添加课程和截图添加课程两个入口。',
    );
  }
}
