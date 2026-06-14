import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/settings.dart';

class SemesterListPage extends StatefulWidget {
  const SemesterListPage({super.key});

  @override
  State<SemesterListPage> createState() => _SemesterListPageState();
}

class _SemesterListPageState extends State<SemesterListPage> {
  late Future<SemesterSettings> _settingsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  void _reload() {
    _settingsFuture = AppScope.repositoriesOf(
      context,
    ).settings.getSemesterSettings();
  }

  Future<void> _openDetail([String? semesterId]) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.semesterDetail,
      arguments: SemesterDetailRouteArgs(semesterId: semesterId),
    );
    if (mounted) {
      setState(_reload);
    }
  }

  Future<void> _deleteSemester(SemesterTimetable semester) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除学期课表？',
      message: '删除后不会删除已有课程，但这些课程将不再出现在该学期课表中。',
      confirmText: '删除',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await AppScope.repositoriesOf(
      context,
    ).settings.deleteSemesterTimetable(semester.id);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: '管理学期课表',
              onBack: () => Navigator.of(context).maybePop(),
              trailing: IconButton(
                tooltip: '添加学期',
                onPressed: () => _openDetail(),
                icon: const Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<SemesterSettings>(
                future: _settingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppCard(child: LoadingState());
                  }
                  if (snapshot.hasError) {
                    return const AppCard(
                      child: ErrorState(message: '无法读取学期课表。'),
                    );
                  }
                  final semesters = [...(snapshot.data?.semesters ?? const [])]
                    ..sort(
                      (a, b) =>
                          a.semesterStartDate.compareTo(b.semesterStartDate),
                    );
                  if (semesters.isEmpty) {
                    return AppCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const EmptyState(
                            title: '暂无学期课表',
                            message: '点击右上角加号添加学期。',
                            icon: Icons.calendar_month_outlined,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => _openDetail(),
                            child: const Text('添加学期'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: semesters.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final semester = semesters[index];
                      return _SemesterTile(
                        semester: semester,
                        onTap: () => _openDetail(semester.id),
                        onLongPress: () => _deleteSemester(semester),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemesterDetailPage extends StatefulWidget {
  const SemesterDetailPage({this.semesterId, super.key});

  final String? semesterId;

  @override
  State<SemesterDetailPage> createState() => _SemesterDetailPageState();
}

class _SemesterDetailPageState extends State<SemesterDetailPage> {
  var _loading = true;
  var _saving = false;
  String? _error;
  String? _id;
  String _owner = '我';
  String _schoolYear = '2025-2026';
  SemesterTermType _termType = SemesterTermType.spring;
  DateTime _startDate = DateTime(2026, 3, 2);
  int _weekCount = 16;
  DateTime _createdAt = DateTime(2026, 3, 2);

  bool get _isEdit => widget.semesterId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final repos = AppScope.repositoriesOf(context);
    final settings = await repos.settings.getSemesterSettings();
    if (!mounted) {
      return;
    }
    final id = widget.semesterId;
    if (id != null) {
      final semester = settings.semesterById(id);
      if (semester == null) {
        setState(() {
          _loading = false;
          _error = '学期课表不存在';
        });
        return;
      }
      _id = semester.id;
      _owner = semester.owner;
      _schoolYear = semester.schoolYear;
      _termType = semester.termType;
      _startDate = semester.semesterStartDate;
      _weekCount = semester.weekCount;
      _createdAt = semester.createdAt;
      _updatedAt = semester.updatedAt;
    } else {
      final seedDate = _suggestStartDate(settings);
      final now = AppScope.clockOf(context).now();
      _id = 'semester-${now.microsecondsSinceEpoch}';
      _owner = '我';
      _schoolYear = _schoolYearForDate(seedDate);
      _termType = _termTypeForDate(seedDate);
      _startDate = seedDate;
      _createdAt = now;
      _updatedAt = now;
    }
    setState(() => _loading = false);
  }

  DateTime _updatedAt = DateTime(2026, 3, 2);

  String get _generatedName =>
      generatedSemesterName(_owner, _schoolYear, _termType);

  Future<void> _editOwner() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _OwnerDialog(initialOwner: _owner),
    );
    if (value == null || !mounted) {
      return;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      showAppSnackBar(context, '请填写课表归属。');
      return;
    }
    setState(() => _owner = trimmed);
  }

  Future<void> _pickSchoolYear() async {
    final currentStart = int.tryParse(_schoolYear.split('-').first) ?? 2025;
    final years = [
      for (var year = currentStart - 2; year <= currentStart + 4; year++)
        '$year-${year + 1}',
    ];
    final selected = await _pickString(
      title: '选择学年范围',
      values: years,
      current: _schoolYear,
    );
    if (selected != null && mounted) {
      setState(() => _schoolYear = selected);
    }
  }

  Future<void> _pickTermType() async {
    final selected = await showDialog<SemesterTermType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('选择学期类型'),
          children: [
            for (final type in SemesterTermType.values)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(type),
                child: Row(
                  children: [
                    Expanded(child: Text(type.label)),
                    if (type == _termType)
                      const Icon(Icons.check, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _termType = selected);
    }
  }

  Future<String?> _pickString({
    required String title,
    required List<String> values,
    required String current,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: [
            for (final value in values)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(value),
                child: Row(
                  children: [
                    Expanded(child: Text(value)),
                    if (value == current)
                      const Icon(Icons.check, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
    );
    if (date != null && mounted) {
      setState(() {
        _startDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  Future<void> _editWeekCount() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => _WeekCountDialog(initialWeekCount: _weekCount),
    );
    if (value == null || !mounted) {
      return;
    }
    if (value < 1 || value > 30) {
      showAppSnackBar(context, '学期持续周数需在 1-30 周之间。');
      return;
    }
    setState(() => _weekCount = value);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final semester = SemesterTimetable(
      id: _id!,
      name: _generatedName,
      owner: _owner,
      schoolYear: _schoolYear,
      termType: _termType,
      semesterStartDate: _startDate,
      weekCount: _weekCount,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
    );
    try {
      await AppScope.repositoriesOf(
        context,
      ).settings.saveSemesterTimetable(semester);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      showAppSnackBar(context, _friendlyError(error));
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).maybePop();
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
        child: Column(
          children: [
            AppHeader(
              title: _isEdit ? '编辑学期' : '添加学期',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : AppCard(
                      radius: 12,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _DetailRow(
                            title: '课表归属',
                            value: _owner,
                            onTap: _editOwner,
                          ),
                          const _Divider(),
                          _InfoRow(title: '课表名称', value: _generatedName),
                          const _Divider(),
                          _DetailRow(
                            title: '学年范围',
                            value: _schoolYear,
                            onTap: _pickSchoolYear,
                          ),
                          const _Divider(),
                          _DetailRow(
                            title: '学期类型',
                            value: _termType.label,
                            onTap: _pickTermType,
                          ),
                          const _Divider(),
                          _DetailRow(
                            title: '开学日期',
                            value: _formatDate(_startDate),
                            onTap: _pickStartDate,
                          ),
                          const _Divider(),
                          _DetailRow(
                            title: '持续周数',
                            value: '$_weekCount 周',
                            onTap: _editWeekCount,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving || _loading ? null : _save,
                child: Text(_saving ? '保存中...' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterTile extends StatelessWidget {
  const _SemesterTile({
    required this.semester,
    required this.onTap,
    required this.onLongPress,
  });

  final SemesterTimetable semester;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 12,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester.displayName,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(semester.semesterStartDate)} - '
                      '${_formatDate(semester.semesterEndDate)} · '
                      '${semester.weekCount} 周',
                      style: const TextStyle(
                        color: AppColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.line),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
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
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: AppColors.muted),
                ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
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
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerDialog extends StatefulWidget {
  const _OwnerDialog({required this.initialOwner});

  final String initialOwner;

  @override
  State<_OwnerDialog> createState() => _OwnerDialogState();
}

class _OwnerDialogState extends State<_OwnerDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialOwner,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('课表归属'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 12,
        decoration: const InputDecoration(
          hintText: '例如：我、室友、张三',
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final owner = _controller.text.trim();
            if (owner.isEmpty) {
              showAppSnackBar(context, '请填写课表归属。');
              return;
            }
            Navigator.of(context).pop(owner);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class _WeekCountDialog extends StatefulWidget {
  const _WeekCountDialog({required this.initialWeekCount});

  final int initialWeekCount;

  @override
  State<_WeekCountDialog> createState() => _WeekCountDialogState();
}

class _WeekCountDialogState extends State<_WeekCountDialog> {
  late int _value = widget.initialWeekCount.clamp(1, 30).toInt();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('持续周数'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: '减少一周',
            onPressed: _value <= 1 ? null : () => setState(() => _value -= 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 96,
            child: Text(
              '$_value 周',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: '增加一周',
            onPressed: _value >= 30 ? null : () => setState(() => _value += 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, color: AppColors.line);
  }
}

DateTime _suggestStartDate(SemesterSettings settings) {
  if (settings.semesters.isEmpty) {
    return DateTime(2026, 3, 2);
  }
  final latest = [...settings.semesters]
    ..sort((a, b) => b.semesterEndDate.compareTo(a.semesterEndDate));
  return latest.first.semesterEndDate.add(const Duration(days: 1));
}

String _friendlyError(Object error) {
  if (error is StateError) {
    return error.message;
  }
  if (error is ArgumentError) {
    return error.message?.toString() ?? '学期设置不合法。';
  }
  return '无法保存学期课表。';
}

String _formatDate(DateTime date) {
  return '${date.year}.${date.month}.${date.day}';
}

String _schoolYearForDate(DateTime date) {
  if (date.month >= 8) {
    return '${date.year}-${date.year + 1}';
  }
  return '${date.year - 1}-${date.year}';
}

SemesterTermType _termTypeForDate(DateTime date) {
  return date.month <= 7 ? SemesterTermType.spring : SemesterTermType.autumn;
}
