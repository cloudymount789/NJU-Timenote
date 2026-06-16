import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/todo.dart';
import 'todo_tag_page.dart';

class TodoDetailPage extends StatefulWidget {
  const TodoDetailPage({required this.isCreate, this.todoId, super.key});

  final bool isCreate;
  final String? todoId;

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _location = TextEditingController();
  TodoKind _kind = TodoKind.normal;
  DateTime? _startAt;
  DateTime? _endAt;
  DateTime? _deadlineAt;
  double _priority = 0;
  List<String> _tags = [];
  RepeatRule _repeatRule = RepeatRule.once;
  TodoStatus _status = TodoStatus.open;
  _TodoEditSnapshot? _savedSnapshot;
  var _loading = true;
  var _didLoad = false;
  var _leaving = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  Future<void> _load() async {
    if (widget.isCreate) {
      _savedSnapshot = _currentSnapshot();
      setState(() => _loading = false);
      return;
    }
    final id = widget.todoId;
    if (id == null) {
      setState(() {
        _loading = false;
        _error = '缺少待办 ID';
      });
      return;
    }
    final todo = await AppScope.repositoriesOf(context).todos.getTodoById(id);
    if (todo == null) {
      setState(() {
        _loading = false;
        _error = '待办不存在';
      });
      return;
    }
    _title.text = todo.title;
    _content.text = todo.content;
    _location.text = todo.location;
    setState(() {
      _kind = todo.kind;
      _startAt = todo.startAt;
      _endAt = todo.endAt;
      _deadlineAt = todo.deadlineAt;
      _priority = todo.priority;
      _tags = [...todo.tags];
      _repeatRule = todo.repeatRule;
      _status = todo.status;
      _savedSnapshot = _currentSnapshot();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final saved = _savedSnapshot;
    if (_loading || _error != null || saved == null) {
      return false;
    }
    return _currentSnapshot() != saved;
  }

  _TodoEditSnapshot _currentSnapshot() {
    return _TodoEditSnapshot(
      title: _title.text.trim(),
      content: _content.text,
      location: _location.text,
      kind: _kind,
      startAt: _kind == TodoKind.duration ? _startAt : null,
      endAt: _kind == TodoKind.duration ? _endAt : null,
      deadlineAt: _kind == TodoKind.deadline ? _deadlineAt : null,
      priority: _priority,
      tags: _tags,
      repeatRule: _repeatRule,
      status: _status,
    );
  }

  Future<bool> _save({bool leaveAfterSave = true}) async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      _showMessage('标题不能为空');
      return false;
    }
    if (_kind == TodoKind.deadline && _deadlineAt == null) {
      _showMessage('请设置 DDL 时间');
      return false;
    }
    if (_kind == TodoKind.duration &&
        (_startAt == null || _endAt == null || !_startAt!.isBefore(_endAt!))) {
      _showMessage('请设置有效的起止时间');
      return false;
    }
    try {
      final repo = AppScope.repositoriesOf(context).todos;
      if (widget.isCreate) {
        await repo.createTodo(
          TodoDraft(
            title: title,
            content: _content.text,
            location: _location.text,
            kind: _kind,
            startAt: _kind == TodoKind.duration ? _startAt : null,
            endAt: _kind == TodoKind.duration ? _endAt : null,
            deadlineAt: _kind == TodoKind.deadline ? _deadlineAt : null,
            priority: _priority,
            tags: _tags,
            repeatRule: _repeatRule,
          ),
        );
      } else {
        await repo.updateTodo(
          widget.todoId!,
          TodoPatch(
            title: PatchField.value(title),
            content: PatchField.value(_content.text),
            location: PatchField.value(_location.text),
            kind: PatchField.value(_kind),
            startAt: PatchField.value(
              _kind == TodoKind.duration ? _startAt : null,
            ),
            endAt: PatchField.value(_kind == TodoKind.duration ? _endAt : null),
            deadlineAt: PatchField.value(
              _kind == TodoKind.deadline ? _deadlineAt : null,
            ),
            priority: PatchField.value(_priority),
            tags: PatchField.value(_tags),
            repeatRule: PatchField.value(_repeatRule),
            status: PatchField.value(_status),
          ),
        );
      }
      _savedSnapshot = _currentSnapshot();
      if (mounted) {
        if (leaveAfterSave) {
          _forcePop(true);
        } else {
          setState(() {});
        }
      }
      return true;
    } catch (error) {
      _showMessage('保存失败：$error');
      return false;
    }
  }

  Future<void> _requestLeave() async {
    if (_leaving) {
      return;
    }
    if (!_hasUnsavedChanges) {
      _forcePop(false);
      return;
    }
    final action = await showAppUnsavedChangesDialog(context: context);
    if (!mounted) {
      return;
    }
    switch (action) {
      case AppUnsavedAction.save:
        await _save();
      case AppUnsavedAction.discard:
        _forcePop(false);
      case AppUnsavedAction.cancel:
      case null:
        break;
    }
  }

  void _forcePop([bool result = false]) {
    if (!mounted) {
      return;
    }
    _leaving = true;
    Navigator.of(context).pop(result);
  }

  Future<void> _delete() async {
    final repo = AppScope.repositoriesOf(context).todos;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除待办',
      message: '确认删除这个待办？',
      confirmText: '删除',
    );
    if (confirmed != true) {
      return;
    }
    try {
      await repo.deleteTodo(widget.todoId!);
      if (mounted) {
        _forcePop(true);
      }
    } catch (error) {
      _showMessage('删除失败：$error');
    }
  }

  Future<DateTime?> _pickDateTime({
    required String label,
    DateTime? initial,
  }) async {
    final seed = initial ?? AppScope.clockOf(context).now();
    final date = await showDatePicker(
      context: context,
      initialDate: seed,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(seed),
      helpText: label,
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickTime({
    required String label,
    required ValueChanged<DateTime> onPicked,
    DateTime? initial,
  }) async {
    final value = await _pickDateTime(label: label, initial: initial);
    if (value == null) {
      return;
    }
    onPicked(value);
  }

  Future<void> _pickOnceDurationStart() async {
    final start = await _pickDateTime(label: '选择开始时间', initial: _startAt);
    if (start == null || !mounted) {
      return;
    }
    final defaultEnd = defaultDurationEndForStart(start);
    setState(() {
      _startAt = start;
      _endAt = defaultEnd;
    });
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(defaultEnd),
      helpText: '选择结束时间',
    );
    if (endTime == null || !mounted) {
      return;
    }
    setState(() {
      _endAt = durationEndOnOrAfterStart(start, endTime);
    });
  }

  Future<void> _pickRepeatDeadline() async {
    final seed = _deadlineAt ?? AppScope.clockOf(context).now();
    var date = seed;
    if (_repeatRule == RepeatRule.weekly ||
        _repeatRule == RepeatRule.biweekly) {
      final weekday = await _pickWeekday(seed.weekday);
      if (weekday == null || !mounted) {
        return;
      }
      date = _dateForWeekday(AppScope.clockOf(context).now(), weekday);
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(seed),
      helpText: '选择 DDL 时间',
    );
    if (time == null) {
      return;
    }
    setState(() {
      _deadlineAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickRepeatDuration() async {
    final now = AppScope.clockOf(context).now();
    final startSeed = _startAt ?? now;
    final endSeed = _endAt ?? startSeed.add(const Duration(hours: 1));
    var date = startSeed;
    if (_repeatRule == RepeatRule.weekly ||
        _repeatRule == RepeatRule.biweekly) {
      final weekday = await _pickWeekday(startSeed.weekday);
      if (weekday == null || !mounted) {
        return;
      }
      date = _dateForWeekday(now, weekday);
    } else {
      date = DateTime(now.year, now.month, now.day);
    }
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startSeed),
      helpText: '选择开始时间',
    );
    if (startTime == null || !mounted) {
      return;
    }
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endSeed),
      helpText: '选择结束时间',
    );
    if (endTime == null) {
      return;
    }
    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      _endAt = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );
    });
  }

  Future<int?> _pickWeekday(int initialWeekday) {
    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择周几'),
        children: [
          for (var weekday = 1; weekday <= 7; weekday += 1)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(weekday),
              child: Row(
                children: [
                  Expanded(child: Text(_weekdayName(weekday))),
                  if (weekday == initialWeekday)
                    const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openTags() async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoTags,
      arguments: TodoTagRouteArgs(initialTags: _tags),
    );
    if (result is List<String>) {
      setState(() => _tags = result);
    }
  }

  Future<void> _openRepeatDialog() async {
    final result = await showDialog<RepeatRule>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '重复',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                ...RepeatRule.values.map(
                  (rule) => ListTile(
                    title: Text(_repeatLabel(rule)),
                    trailing: _repeatRule == rule
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(rule),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _repeatRule = result;
        _coerceRepeatTimes();
      });
    }
  }

  void _setKind(TodoKind kind) {
    setState(() {
      _kind = kind;
      if (kind == TodoKind.normal) {
        _startAt = null;
        _endAt = null;
        _deadlineAt = null;
      } else if (kind == TodoKind.deadline) {
        _startAt = null;
        _endAt = null;
      } else {
        _deadlineAt = null;
      }
      _coerceRepeatTimes();
    });
  }

  void _coerceRepeatTimes() {
    if (_repeatRule == RepeatRule.once) {
      return;
    }
    final now = AppScope.clockOf(context).now();
    final date = DateTime(now.year, now.month, now.day);
    if (_kind == TodoKind.deadline && _deadlineAt == null) {
      _deadlineAt = DateTime(date.year, date.month, date.day, 23, 59);
    }
    if (_kind == TodoKind.duration) {
      _startAt ??= DateTime(date.year, date.month, date.day, now.hour, 0);
      _endAt ??= _startAt!.add(const Duration(hours: 1));
    }
  }

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _requestLeave();
        }
      },
      child: GradientPageScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
          child: Column(
            children: [
              AppHeader(
                title: widget.isCreate ? '新建待办' : '待办详情',
                onBack: _requestLeave,
                trailing: widget.isCreate
                    ? null
                    : AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: '删除待办',
                        onPressed: _delete,
                      ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _loading
                    ? const LoadingState()
                    : _error != null
                    ? ErrorState(message: _error!)
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _FormCard(
                              children: [
                                _Input(label: '标题', controller: _title),
                                _Input(
                                  label: '内容',
                                  controller: _content,
                                  maxLines: 3,
                                ),
                                _Input(label: '地点', controller: _location),
                                _PickerRow(
                                  label: '重复',
                                  value: _repeatLabel(_repeatRule),
                                  onTap: _openRepeatDialog,
                                ),
                                _KindSelector(
                                  value: _kind,
                                  onChanged: _setKind,
                                ),
                                if (_kind == TodoKind.duration) ...[
                                  _PickerRow(
                                    label: _repeatRule == RepeatRule.once
                                        ? '开始时间'
                                        : '重复时段',
                                    value: _repeatRule == RepeatRule.once
                                        ? _formatDateTime(_startAt)
                                        : _formatRepeatRange(
                                            _repeatRule,
                                            _startAt,
                                            _endAt,
                                          ),
                                    onTap: _repeatRule == RepeatRule.once
                                        ? _pickOnceDurationStart
                                        : _pickRepeatDuration,
                                  ),
                                  if (_repeatRule == RepeatRule.once)
                                    _PickerRow(
                                      label: '结束时间',
                                      value: _formatDateTime(_endAt),
                                      onTap: () => _pickTime(
                                        label: '选择结束时间',
                                        initial: _endAt,
                                        onPicked: (value) =>
                                            setState(() => _endAt = value),
                                      ),
                                    ),
                                ],
                                if (_kind == TodoKind.deadline)
                                  _PickerRow(
                                    label: 'DDL',
                                    value: _repeatRule == RepeatRule.once
                                        ? _formatDateTime(_deadlineAt)
                                        : _formatRepeatDeadline(
                                            _repeatRule,
                                            _deadlineAt,
                                          ),
                                    onTap: _repeatRule == RepeatRule.once
                                        ? () => _pickTime(
                                            label: '选择 DDL',
                                            initial: _deadlineAt,
                                            onPicked: (value) => setState(
                                              () => _deadlineAt = value,
                                            ),
                                          )
                                        : _pickRepeatDeadline,
                                  ),
                                _PriorityInput(
                                  value: _priority,
                                  onChanged: (value) =>
                                      setState(() => _priority = value),
                                ),
                                _PickerRow(
                                  label: 'Tag',
                                  value: _tags.isEmpty
                                      ? '未选择'
                                      : _tags.join('、'),
                                  onTap: _openTags,
                                  key: const ValueKey('todo-tag-picker'),
                                ),
                                if (!widget.isCreate)
                                  _StatusToggleRow(
                                    kind: _kind,
                                    status: _status,
                                    onChanged: (status) =>
                                        setState(() => _status = status),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: _save,
                                child: const Text('保存'),
                              ),
                            ),
                            if (!widget.isCreate) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _delete,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(
                                      color: Color(0xFFFCA5A5),
                                    ),
                                  ),
                                  child: const Text('删除待办'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoEditSnapshot {
  _TodoEditSnapshot({
    required this.title,
    required this.content,
    required this.location,
    required this.kind,
    required this.startAt,
    required this.endAt,
    required this.deadlineAt,
    required this.priority,
    required List<String> tags,
    required this.repeatRule,
    required this.status,
  }) : tags = List.unmodifiable([...tags]..sort());

  final String title;
  final String content;
  final String location;
  final TodoKind kind;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final double priority;
  final List<String> tags;
  final RepeatRule repeatRule;
  final TodoStatus status;

  @override
  bool operator ==(Object other) {
    return other is _TodoEditSnapshot &&
        title == other.title &&
        content == other.content &&
        location == other.location &&
        kind == other.kind &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        deadlineAt == other.deadlineAt &&
        priority == other.priority &&
        _listEquals(tags, other.tags) &&
        repeatRule == other.repeatRule &&
        status == other.status;
  }

  @override
  int get hashCode => Object.hash(
    title,
    content,
    location,
    kind,
    startAt,
    endAt,
    deadlineAt,
    priority,
    Object.hashAll(tags),
    repeatRule,
    status,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220062FF),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});

  final TodoKind value;
  final ValueChanged<TodoKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SegmentedButton<TodoKind>(
        segments: const [
          ButtonSegment(value: TodoKind.duration, label: Text('持续')),
          ButtonSegment(value: TodoKind.deadline, label: Text('DDL')),
          ButtonSegment(value: TodoKind.normal, label: Text('普通')),
        ],
        selected: {value},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _PriorityInput extends StatelessWidget {
  const _PriorityInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 82, child: Text('重要程度')),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 5,
              divisions: 10,
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(value.toStringAsFixed(1), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _StatusToggleRow extends StatelessWidget {
  const _StatusToggleRow({
    required this.kind,
    required this.status,
    required this.onChanged,
  });

  final TodoKind kind;
  final TodoStatus status;
  final ValueChanged<TodoStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kind == TodoKind.duration) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('完成状态'),
        subtitle: Text('持续时间待办按结束时间自动完成，当前不支持手动切换。'),
      );
    }
    final done = status == TodoStatus.done;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('完成状态'),
      subtitle: Text(done ? '已完成' : '未完成'),
      value: done,
      onChanged: (value) =>
          onChanged(value ? TodoStatus.done : TodoStatus.open),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '未设置';
  }
  return '${value.month}.${value.day} ${_weekday(value)} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _formatRepeatDeadline(RepeatRule rule, DateTime? value) {
  if (value == null) {
    return '未设置';
  }
  final time = _formatTime(value);
  return switch (rule) {
    RepeatRule.once => _formatDateTime(value),
    RepeatRule.daily => '每天 $time',
    RepeatRule.weekly => '每周 ${_weekday(value)} $time',
    RepeatRule.biweekly => '每两周 ${_weekday(value)} $time',
  };
}

String _formatRepeatRange(RepeatRule rule, DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return '未设置';
  }
  final range = '${_formatTime(start)} - ${_formatTime(end)}';
  return switch (rule) {
    RepeatRule.once => '${_formatDateTime(start)} - ${_formatTime(end)}',
    RepeatRule.daily => '每天 $range',
    RepeatRule.weekly => '每周 ${_weekday(start)} $range',
    RepeatRule.biweekly => '每两周 ${_weekday(start)} $range',
  };
}

String _formatTime(DateTime value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _repeatLabel(RepeatRule rule) {
  return switch (rule) {
    RepeatRule.once => '仅一次',
    RepeatRule.daily => '每天',
    RepeatRule.weekly => '每周',
    RepeatRule.biweekly => '每两周',
  };
}

String _weekday(DateTime value) {
  return _weekdayName(value.weekday);
}

String _weekdayName(int weekday) {
  return const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][weekday - 1];
}

DateTime _dateForWeekday(DateTime reference, int weekday) {
  final date = DateTime(reference.year, reference.month, reference.day);
  return date.add(Duration(days: weekday - reference.weekday));
}

DateTime defaultDurationEndForStart(DateTime start) {
  return start.add(const Duration(hours: 1));
}

DateTime durationEndOnOrAfterStart(DateTime start, TimeOfDay endTime) {
  var end = DateTime(
    start.year,
    start.month,
    start.day,
    endTime.hour,
    endTime.minute,
  );
  if (!end.isAfter(start)) {
    end = end.add(const Duration(days: 1));
  }
  return end;
}
