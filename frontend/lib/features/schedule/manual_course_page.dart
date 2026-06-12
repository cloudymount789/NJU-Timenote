import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../data/models/course.dart';

class ManualCoursePage extends StatefulWidget {
  const ManualCoursePage({this.courseId, super.key});

  final String? courseId;

  @override
  State<ManualCoursePage> createState() => _ManualCoursePageState();
}

class _ManualCoursePageState extends State<ManualCoursePage> {
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
  bool _saving = false;
  var _loading = true;
  var _didLoad = false;
  String? _error;

  bool get _isEdit => widget.courseId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final id = widget.courseId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final course = await AppScope.repositoriesOf(
      context,
    ).courses.getCourseById(id);
    if (course == null) {
      setState(() {
        _loading = false;
        _error = '课程不存在';
      });
      return;
    }
    _nameController.text = course.name;
    _teacherController.text = course.teacher;
    _locationController.text = course.location;
    _noteController.text = course.note;
    setState(() {
      _weekRule = course.weekRule;
      _startWeek = course.startWeek;
      _endWeek = course.endWeek;
      _dayOfWeek = course.dayOfWeek;
      _startPeriod = course.startPeriod;
      _endPeriod = course.endPeriod;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    String? message;
    if (name.isEmpty) {
      message = '请填写课程名称。';
    } else if (location.isEmpty) {
      message = '请填写上课地点。';
    } else if (_endWeek < _startWeek) {
      message = '结束周不能早于起始周。';
    } else if (_endPeriod < _startPeriod) {
      message = '结束节不能早于起始节。';
    }
    if (message != null) {
      showAppSnackBar(context, message);
      return;
    }

    setState(() => _saving = true);
    final draft = CourseDraft(
      name: name,
      teacher: _teacherController.text,
      location: location,
      note: _noteController.text,
      dayOfWeek: _dayOfWeek,
      startPeriod: _startPeriod,
      endPeriod: _endPeriod,
      weekRule: _weekRule,
      startWeek: _startWeek,
      endWeek: _endWeek,
    );
    final repo = AppScope.repositoriesOf(context).courses;
    if (_isEdit) {
      await repo.updateCourse(widget.courseId!, draft);
    } else {
      await repo.createCourse(draft);
    }
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (_isEdit) {
      Navigator.of(context).maybePop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('/schedule'));
    }
  }

  Future<void> _openWeekPicker() async {
    var rule = _weekRule;
    var start = _startWeek;
    var end = _endWeek;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return PickerShell(
                title: '选择上课周次',
                onConfirm: () {
                  if (end < start) {
                    showAppSnackBar(context, '结束周不能早于起始周。');
                    return;
                  }
                  setState(() {
                    _weekRule = rule;
                    _startWeek = start;
                    _endWeek = end;
                  });
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<WeekRule>(
                        value: rule,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: WeekRule.all,
                            child: Text('全部'),
                          ),
                          DropdownMenuItem(
                            value: WeekRule.odd,
                            child: Text('单周'),
                          ),
                          DropdownMenuItem(
                            value: WeekRule.even,
                            child: Text('双周'),
                          ),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => rule = value ?? rule),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberDropdown(
                        value: start,
                        min: 1,
                        max: 25,
                        label: '起始',
                        onChanged: (value) =>
                            setDialogState(() => start = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberDropdown(
                        value: end,
                        min: 1,
                        max: 25,
                        label: '结束',
                        onChanged: (value) => setDialogState(() => end = value),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openPeriodPicker() async {
    var day = _dayOfWeek;
    var start = _startPeriod;
    var end = _endPeriod;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return PickerShell(
                title: '选择上课时间',
                onConfirm: () {
                  if (end < start) {
                    showAppSnackBar(context, '结束节不能早于起始节。');
                    return;
                  }
                  setState(() {
                    _dayOfWeek = day;
                    _startPeriod = start;
                    _endPeriod = end;
                  });
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Expanded(
                      child: _NumberDropdown(
                        value: day,
                        min: 1,
                        max: 7,
                        label: '周',
                        itemBuilder: (value) => '周${_weekdayName(value)}',
                        onChanged: (value) => setDialogState(() => day = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberDropdown(
                        value: start,
                        min: 1,
                        max: 12,
                        label: '起始',
                        onChanged: (value) =>
                            setDialogState(() => start = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberDropdown(
                        value: end,
                        min: 1,
                        max: 12,
                        label: '结束',
                        onChanged: (value) => setDialogState(() => end = value),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String get _weekText {
    final rule = switch (_weekRule) {
      WeekRule.all => '全部',
      WeekRule.odd => '单周',
      WeekRule.even => '双周',
    };
    return '$_startWeek-$_endWeek周 $rule';
  }

  String get _periodText {
    return '周${_weekdayName(_dayOfWeek)} 第 $_startPeriod-$_endPeriod 节';
  }

  String _weekdayName(int day) {
    return const ['一', '二', '三', '四', '五', '六', '日'][day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            AppHeader(
              title: _isEdit ? '编辑课程' : '手动添加课程',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : SingleChildScrollView(
                      child: AppCard(
                        radius: 12,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('基础信息'),
                            _CourseTextField(
                              label: '课程名称',
                              controller: _nameController,
                              required: true,
                            ),
                            _CourseTextField(
                              label: '任课教师',
                              controller: _teacherController,
                            ),
                            _CourseTextField(
                              label: '地点',
                              controller: _locationController,
                              required: true,
                            ),
                            _CourseTextField(
                              label: '备注',
                              controller: _noteController,
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.line),
                            const SizedBox(height: 18),
                            const _SectionLabel('时间与节次'),
                            _PickerRow(
                              label: '持续周次',
                              value: _weekText,
                              onTap: _openWeekPicker,
                            ),
                            _PickerRow(
                              label: '上课时间',
                              value: _periodText,
                              onTap: _openPeriodPicker,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _saveCourse,
                child: Text(_saving ? '保存中...' : (_isEdit ? '保存课程' : '添加课程')),
              ),
            ),
          ],
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

class _CourseTextField extends StatelessWidget {
  const _CourseTextField({
    required this.label,
    required this.controller,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(value, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.line),
          ],
        ),
      ),
    );
  }
}

class _NumberDropdown extends StatelessWidget {
  const _NumberDropdown({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
    this.itemBuilder,
  });

  final int value;
  final int min;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;
  final String Function(int value)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (var item = min; item <= max; item++)
          DropdownMenuItem(
            value: item,
            child: Text(itemBuilder?.call(item) ?? '$item'),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
