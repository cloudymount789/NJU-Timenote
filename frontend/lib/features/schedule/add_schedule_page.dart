import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';

class AddSchedulePage extends StatelessWidget {
  const AddSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.xl,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        child: Column(
          children: [
            AppHeader(
              title: '添加课表',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 28),
            _OptionCard(
              icon: Icons.edit_calendar_outlined,
              title: '手动添加课程',
              subtitle: '填写课程信息、周次和节次',
              onTap: () async {
                await Navigator.of(
                  context,
                ).pushNamed(AppRoutes.scheduleAddManual);
              },
            ),
            const SizedBox(height: 20),
            _OptionCard(
              icon: Icons.image_search_outlined,
              title: '截图添加课程',
              subtitle: '当前为识别服务未接入的流程壳',
              onTap: () async {
                await Navigator.of(
                  context,
                ).pushNamed(AppRoutes.scheduleAddScreenshot);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 12,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.subtle, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.line),
        ],
      ),
    );
  }
}
