import 'package:flutter/material.dart';

import '../controllers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = TimenoteScope.of(context).settings;
    return AppGradientScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          const StatusHeader(),
          PageTitleBar(title: '设置', onBack: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          const _SectionTitle('课表与作息'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  label: '节次时间',
                  value: '编辑',
                  valueColor: AppColors.accent,
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.border),
                _SettingsRow(
                  label: '学期开学日',
                  value: settings == null
                      ? '9 月 1 日'
                      : '${settings.semesterStartDate.month} 月 ${settings.semesterStartDate.day} 日',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('数据与分享'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  label: '本地备份',
                  value: '立即备份',
                  valueColor: AppColors.accent,
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.border),
                _SettingsRow(label: '导出 / 分享', value: '›', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textSecondary,
    this.onTap,
  });

  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 14, color: valueColor)),
          ],
        ),
      ),
    );
  }
}
