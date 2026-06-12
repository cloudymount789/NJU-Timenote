import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../data/models/goal_split.dart';

class GoalSplitPage extends StatefulWidget {
  const GoalSplitPage({this.initialTitle, super.key});

  final String? initialTitle;

  @override
  State<GoalSplitPage> createState() => _GoalSplitPageState();
}

class _GoalSplitPageState extends State<GoalSplitPage> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _subtaskTitle = TextEditingController();
  var _step = 0;
  DateTime? _finalDeadline;
  DateTime? _subtaskDate;
  final _subtasks = <GoalSubtaskDraft>[];

  @override
  void initState() {
    super.initState();
    _title.text = widget.initialTitle ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _subtaskTitle.dispose();
    super.dispose();
  }

  bool get _canNextSetup {
    return _title.text.trim().isNotEmpty &&
        _finalDeadline != null &&
        !_dateOnly(
          _finalDeadline!,
        ).isBefore(_dateOnly(AppScope.clockOf(context).now()));
  }

  bool get _canReview => _subtasks.isNotEmpty;

  Future<void> _pickFinalDeadline() async {
    final picked = await _pickDate(_finalDeadline);
    if (picked != null) {
      setState(() => _finalDeadline = picked);
    }
  }

  Future<void> _pickSubtaskDate() async {
    final picked = await _pickDate(_subtaskDate);
    if (picked != null) {
      setState(() => _subtaskDate = picked);
    }
  }

  Future<DateTime?> _pickDate(DateTime? initial) {
    final today = AppScope.clockOf(context).now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? today,
      firstDate: today,
      lastDate: DateTime(2035),
    );
  }

  void _addSubtask() {
    final title = _subtaskTitle.text.trim();
    final finalDeadline = _finalDeadline;
    final date = _subtaskDate;
    if (title.isEmpty || date == null || finalDeadline == null) {
      _showMessage('请填写小目标名称和日期');
      return;
    }
    if (_dateOnly(date).isAfter(_dateOnly(finalDeadline))) {
      _showMessage('小目标日期不能晚于最终 DDL');
      return;
    }
    setState(() {
      _subtasks.add(GoalSubtaskDraft(title: title, plannedDate: date));
      _subtaskTitle.clear();
      _subtaskDate = null;
    });
  }

  Future<void> _confirmGenerate() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '确认生成',
      message: '生成后可以在待办详情中单独修改。',
      confirmText: '生成',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await AppScope.repositoriesOf(context).goalSplits.createFromGoalSplit(
        GoalSplitDraft(
          title: _title.text.trim(),
          note: _note.text,
          finalDeadline: _finalDeadline!,
          subtasks: List.unmodifiable(_subtasks),
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/todos');
      }
    } catch (error) {
      _showMessage('生成失败：$error');
    }
  }

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
        child: Column(
          children: [
            AppHeader(
              title: '大目标拆分',
              subtitle: '步骤 ${_step + 1}/3',
              onBack: () {
                if (_step == 0) {
                  Navigator.of(context).pop(_title.text);
                } else {
                  setState(() => _step -= 1);
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildStep()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _buttonEnabled()
                    ? () {
                        if (_step < 2) {
                          setState(() => _step += 1);
                        } else {
                          _confirmGenerate();
                        }
                      }
                    : null,
                child: Text(_step == 2 ? '确认生成' : '下一步'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
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
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: switch (_step) {
          0 => _setup(),
          1 => _breakdown(),
          _ => _review(),
        },
      ),
    );
  }

  Widget _setup() {
    return ListView(
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: '大目标名称'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('最终截止 DDL'),
          subtitle: Text(_formatDate(_finalDeadline)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickFinalDeadline,
        ),
        TextField(
          controller: _note,
          decoration: const InputDecoration(labelText: '备注'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _breakdown() {
    return ListView(
      children: [
        Text('目标：${_title.text.trim()}'),
        const SizedBox(height: 16),
        TextField(
          controller: _subtaskTitle,
          decoration: const InputDecoration(labelText: '小目标名称'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('计划完成日期'),
          subtitle: Text(_formatDate(_subtaskDate)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickSubtaskDate,
        ),
        OutlinedButton.icon(
          onPressed: _addSubtask,
          icon: const Icon(Icons.add),
          label: const Text('添加小目标'),
        ),
        const SizedBox(height: 16),
        ..._subtasks.map(
          (subtask) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(subtask.title),
            subtitle: Text(_formatDate(subtask.plannedDate)),
            trailing: IconButton(
              tooltip: '删除小目标',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => _subtasks.remove(subtask)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _review() {
    final grouped = <String, List<GoalSubtaskDraft>>{};
    for (final subtask in _subtasks) {
      grouped
          .putIfAbsent(_formatDate(subtask.plannedDate), () => [])
          .add(subtask);
    }
    return ListView(
      children: [
        Text(
          _title.text.trim(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text('最终 DDL：${_formatDate(_finalDeadline)}'),
        const SizedBox(height: 16),
        ...grouped.entries.expand(
          (entry) => [
            Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            ...entry.value.map(
              (subtask) => ListTile(title: Text(subtask.title)),
            ),
          ],
        ),
      ],
    );
  }

  bool _buttonEnabled() {
    return switch (_step) {
      0 => _canNextSetup,
      1 => _canReview,
      _ => _canReview,
    };
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '未设置';
  }
  return '${value.year}.${value.month}.${value.day}';
}
