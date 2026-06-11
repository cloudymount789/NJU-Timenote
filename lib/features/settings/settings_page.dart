import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../data/models/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepository = AppScope.repositoriesOf(context).settings;

    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          AppSpacing.xl,
          20,
          AppSpacing.pageBottom,
        ),
        child: FutureBuilder<SemesterSettings>(
          future: settingsRepository.getSemesterSettings(),
          builder: (context, snapshot) {
            final startDate = snapshot.data?.semesterStartDate;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: '设置',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 28),
                const _SectionLabel('课表与作息'),
                const SizedBox(height: 8),
                AppCard(
                  radius: 12,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _SettingsRow(
                        title: '节次时间',
                        value: '待后续实现',
                        enabled: false,
                      ),
                      _Divider(),
                      _SettingsRow(
                        title: '学期开学日',
                        value: startDate == null
                            ? '待设置'
                            : '${startDate.year}.${startDate.month}.${startDate.day}',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('数据与分享'),
                const SizedBox(height: 8),
                AppCard(
                  radius: 12,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _SettingsRow(
                        title: '本地备份',
                        value: '待后续实现',
                        enabled: false,
                      ),
                      _Divider(),
                      const _SettingsRow(
                        title: '导出分享',
                        value: '待后续实现',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    required this.enabled,
  });

  final String title;
  final String value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(color: AppColors.subtle, fontSize: 13),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.line),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, color: AppColors.line);
  }
}
