import 'package:flutter/material.dart';

import '../app.dart';
import '../controllers/app_state.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class ManualCourseScreen extends StatefulWidget {
  const ManualCourseScreen({super.key});

  @override
  State<ManualCourseScreen> createState() => _ManualCourseScreenState();
}

class _ManualCourseScreenState extends State<ManualCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  WeekRule _weekRule = WeekRule.all;
  int _startWeek = 1;
  int _endWeek = 25;
  int _dayOfWeek = 1;
  int _startPeriod = 1;
  int _endPeriod = 1;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                const StatusHeader(),
                PageTitleBar(
                  title: '添加课程',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                children: [
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '基础信息',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _CourseTextField(
                          key: const Key('course-name-field'),
                          controller: _nameController,
                          icon: Icons.menu_book_outlined,
                          hintText: '课程名称',
                          validator: _required('请输入课程名称'),
                        ),
                        _CourseTextField(
                          controller: _teacherController,
                          icon: Icons.person_outline,
                          hintText: '任课教师',
                        ),
                        _CourseTextField(
                          key: const Key('course-location-field'),
                          controller: _locationController,
                          icon: Icons.location_on_outlined,
                          hintText: '地点',
                          validator: _required('请输入地点'),
                        ),
                        _CourseTextField(
                          controller: _noteController,
                          icon: Icons.note_alt_outlined,
                          hintText: '备注',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '时间与节次',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _PickerRow(
                          key: const Key('week-picker-row'),
                          icon: Icons.calendar_today_outlined,
                          label:
                              '$_startWeek-$_endWeek周 ${weekRuleLabel(_weekRule)}',
                          onTap: _showWeekPicker,
                        ),
                        _PickerRow(
                          key: const Key('period-picker-row'),
                          icon: Icons.access_time,
                          label:
                              '${PeriodRange.weekdayLabels[_dayOfWeek - 1]} 第 $_startPeriod-$_endPeriod 节',
                          onTap: _showPeriodPicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: FilledButton(
                key: const Key('submit-course-button'),
                onPressed: _isSaving ? null : _submit,
                child: Text(_isSaving ? '添加中...' : '添加课程'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  Future<void> _showWeekPicker() async {
    final selection = await showDialog<_WeekSelection>(
      context: context,
      builder: (context) => _WeekPickerDialog(
        initialRule: _weekRule,
        initialStartWeek: _startWeek,
        initialEndWeek: _endWeek,
      ),
    );
    if (selection != null) {
      setState(() {
        _weekRule = selection.rule;
        _startWeek = selection.startWeek;
        _endWeek = selection.endWeek;
      });
    }
  }

  Future<void> _showPeriodPicker() async {
    final selection = await showDialog<_PeriodSelection>(
      context: context,
      builder: (context) => _PeriodPickerDialog(
        initialDayOfWeek: _dayOfWeek,
        initialStartPeriod: _startPeriod,
        initialEndPeriod: _endPeriod,
      ),
    );
    if (selection != null) {
      setState(() {
        _dayOfWeek = selection.dayOfWeek;
        _startPeriod = selection.startPeriod;
        _endPeriod = selection.endPeriod;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    final state = TimenoteScope.of(context);
    await state.addCourse(
      CourseDraft(
        name: _nameController.text.trim(),
        teacher: _teacherController.text.trim(),
        location: _locationController.text.trim(),
        note: _noteController.text.trim(),
        dayOfWeek: _dayOfWeek,
        startPeriod: _startPeriod,
        endPeriod: _endPeriod,
        weekRule: _weekRule,
        startWeek: _startWeek,
        endWeek: _endWeek,
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.timetable, (route) => route.isFirst);
  }
}

class _CourseTextField extends StatelessWidget {
  const _CourseTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        icon: Icon(icon, color: AppColors.textMuted),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _WeekSelection {
  const _WeekSelection(this.rule, this.startWeek, this.endWeek);

  final WeekRule rule;
  final int startWeek;
  final int endWeek;
}

class _PeriodSelection {
  const _PeriodSelection(this.dayOfWeek, this.startPeriod, this.endPeriod);

  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
}

class _WeekPickerDialog extends StatefulWidget {
  const _WeekPickerDialog({
    required this.initialRule,
    required this.initialStartWeek,
    required this.initialEndWeek,
  });

  final WeekRule initialRule;
  final int initialStartWeek;
  final int initialEndWeek;

  @override
  State<_WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<_WeekPickerDialog> {
  late WeekRule _rule = widget.initialRule;
  late int _startWeek = widget.initialStartWeek;
  late int _endWeek = widget.initialEndWeek;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课时间'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButton<WeekRule>(
              value: _rule,
              isExpanded: true,
              items: WeekRule.values
                  .map(
                    (rule) => DropdownMenuItem(
                      value: rule,
                      child: Text(weekRuleLabel(rule)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _rule = value ?? _rule),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _weekDropdown(
              _startWeek,
              (value) => setState(() => _startWeek = value),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _weekDropdown(
              _endWeek,
              (value) => setState(
                () => _endWeek = value < _startWeek ? _startWeek : value,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          key: const Key('confirm-week-picker'),
          onPressed: () => Navigator.of(
            context,
          ).pop(_WeekSelection(_rule, _startWeek, _endWeek)),
          child: const Text('确认'),
        ),
      ],
    );
  }

  DropdownButton<int> _weekDropdown(int value, ValueChanged<int> onChanged) {
    return DropdownButton<int>(
      value: value,
      isExpanded: true,
      items: [
        for (var week = 1; week <= 25; week++)
          DropdownMenuItem(value: week, child: Text('第 $week 周')),
      ],
      onChanged: (value) => onChanged(value ?? _startWeek),
    );
  }
}

class _PeriodPickerDialog extends StatefulWidget {
  const _PeriodPickerDialog({
    required this.initialDayOfWeek,
    required this.initialStartPeriod,
    required this.initialEndPeriod,
  });

  final int initialDayOfWeek;
  final int initialStartPeriod;
  final int initialEndPeriod;

  @override
  State<_PeriodPickerDialog> createState() => _PeriodPickerDialogState();
}

class _PeriodPickerDialogState extends State<_PeriodPickerDialog> {
  late int _day = widget.initialDayOfWeek;
  late int _start = widget.initialStartPeriod;
  late int _end = widget.initialEndPeriod;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课时间'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: _day,
              isExpanded: true,
              items: [
                for (var day = 1; day <= 7; day++)
                  DropdownMenuItem(
                    value: day,
                    child: Text(PeriodRange.weekdayLabels[day - 1]),
                  ),
              ],
              onChanged: (value) => setState(() => _day = value ?? _day),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _periodDropdown(
              _start,
              (value) => setState(() => _start = value),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _periodDropdown(
              _end,
              (value) => setState(() => _end = value < _start ? _start : value),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          key: const Key('confirm-period-picker'),
          onPressed: () =>
              Navigator.of(context).pop(_PeriodSelection(_day, _start, _end)),
          child: const Text('确认'),
        ),
      ],
    );
  }

  DropdownButton<int> _periodDropdown(int value, ValueChanged<int> onChanged) {
    return DropdownButton<int>(
      value: value,
      isExpanded: true,
      items: [
        for (var period = 1; period <= 12; period++)
          DropdownMenuItem(value: period, child: Text('第 $period 节')),
      ],
      onChanged: (value) => onChanged(value ?? _start),
    );
  }
}
