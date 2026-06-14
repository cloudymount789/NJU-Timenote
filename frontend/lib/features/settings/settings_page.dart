import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../data/models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<SemesterSettings> _settingsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsFuture = AppScope.repositoriesOf(
      context,
    ).settings.getSemesterSettings();
  }

  void _reload() {
    _settingsFuture = AppScope.repositoriesOf(
      context,
    ).settings.getSemesterSettings();
  }

  Future<void> _addSemester() async {
    await AppScope.repositoriesOf(context).settings.addSemesterTimetable(
      startDate: DateTime(2026, 3, 2),
      weekCount: 16,
    );
    if (!mounted) {
      return;
    }
    setState(_reload);
  }

  Future<void> _pickStartDate(SemesterTimetable semester) async {
    final date = await showDatePicker(
      context: context,
      initialDate: semester.semesterStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
    );
    if (date == null || !mounted) {
      return;
    }
    await AppScope.repositoriesOf(context).settings.updateSemesterTimetable(
      semester.copyWith(
        semesterStartDate: DateTime(date.year, date.month, date.day),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(_reload);
  }

  Future<void> _editWeekCount(SemesterTimetable semester) async {
    final controller = TextEditingController(text: '${semester.weekCount}');
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('学期持续周数'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: '请输入 1-25 的整数'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(int.tryParse(controller.text));
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (value == null || !mounted) {
      return;
    }
    if (value < 1 || value > 25) {
      showAppSnackBar(context, '学期持续周数需在 1-25 周之间。');
      return;
    }
    await AppScope.repositoriesOf(
      context,
    ).settings.updateSemesterTimetable(semester.copyWith(weekCount: value));
    if (!mounted) {
      return;
    }
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          AppSpacing.xl,
          20,
          AppSpacing.pageBottom,
        ),
        child: FutureBuilder<SemesterSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            final semesters = snapshot.data?.semesters ?? const [];
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
                      _SettingsRow(
                        title: '管理学期课表',
                        value: '添加',
                        enabled: true,
                        onTap: _addSemester,
                      ),
                      if (semesters.isNotEmpty) _Divider(),
                      for (var index = 0; index < semesters.length; index += 1)
                        _SemesterPanel(
                          semester: semesters[index],
                          isLast: index == semesters.length - 1,
                          onPickStartDate: () =>
                              _pickStartDate(semesters[index]),
                          onEditWeekCount: () =>
                              _editWeekCount(semesters[index]),
                        ),
                      if (snapshot.connectionState != ConnectionState.done)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: LinearProgressIndicator(),
                        ),
                      _Divider(),
                      const _SettingsRow(
                        title: '节次时间',
                        value: '待后续实现',
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
    this.onTap,
  });

  final String title;
  final String value;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
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
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.line,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SemesterPanel extends StatelessWidget {
  const _SemesterPanel({
    required this.semester,
    required this.isLast,
    required this.onPickStartDate,
    required this.onEditWeekCount,
  });

  final SemesterTimetable semester;
  final bool isLast;
  final VoidCallback onPickStartDate;
  final VoidCallback onEditWeekCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  semester.name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_formatDate(semester.semesterStartDate)} - '
                '${_formatDate(semester.semesterEndDate)}',
                style: const TextStyle(color: AppColors.subtle, fontSize: 12),
              ),
            ],
          ),
        ),
        _SettingsRow(
          title: '学期开学日期',
          value: _formatDate(semester.semesterStartDate),
          enabled: true,
          onTap: onPickStartDate,
        ),
        _SettingsRow(
          title: '学期持续周数',
          value: '${semester.weekCount} 周',
          enabled: true,
          onTap: onEditWeekCount,
        ),
        if (!isLast) _Divider(),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, color: AppColors.line);
  }
}

String _formatDate(DateTime date) {
  return '${date.year}.${date.month}.${date.day}';
}
