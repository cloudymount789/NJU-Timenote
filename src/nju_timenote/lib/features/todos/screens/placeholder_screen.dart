import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shell.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatusHeader(),
            PageTitleBar(
              title: title,
              trailing: title == '待办'
                  ? IconButton(
                      tooltip: '批量操作',
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.batchTodos),
                      icon: const Icon(
                        Icons.checklist_rtl,
                        color: AppColors.accent,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 28),
            SoftCard(
              child: Column(
                children: [
                  const CircleIcon(icon: Icons.construction_outlined, size: 54),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
