import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AddCourseEntryScreen extends StatelessWidget {
  const AddCourseEntryScreen({super.key});

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
              title: '添加课表',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 28),
            _AddOptionCard(
              key: const Key('manual-course-option'),
              icon: Icons.edit_outlined,
              iconBackground: const Color(0xFFEAF2FF),
              title: '手动添加课程',
              subtitle: '填写课程名称、时间、地点等信息',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.manualCourse),
            ),
            const SizedBox(height: 18),
            _AddOptionCard(
              key: const Key('screenshot-course-option'),
              icon: Icons.image_outlined,
              iconBackground: const Color(0xFFF1E8FF),
              title: '截图添加课程',
              subtitle: '导入课表截图，自动识别并添加课程',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.screenshotCourse),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  const _AddOptionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleIcon(icon: icon, background: iconBackground),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
