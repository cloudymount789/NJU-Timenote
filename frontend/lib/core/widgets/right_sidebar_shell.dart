import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class RightSidebarShell extends StatelessWidget {
  const RightSidebarShell({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 280,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 54, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
