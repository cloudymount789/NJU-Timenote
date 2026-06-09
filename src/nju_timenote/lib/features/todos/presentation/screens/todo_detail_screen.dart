import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';
import '../widgets/todo_widgets.dart';

class TodoDetailScreen extends ConsumerStatefulWidget {
  const TodoDetailScreen({super.key});

  @override
  ConsumerState<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends ConsumerState<TodoDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  String? _todoId;
  TodoKind _kind = TodoKind.normal;
  DateTime? _startAt;
  DateTime? _endAt;
  DateTime? _deadlineAt;
  double _priority = 3;
  List<String> _tags = [];
  RepeatRule _repeatRule = RepeatRule.once;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosControllerProvider);

    return AppGradientScaffold(
      child: todosState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('待办加载失败：$error')),
        data: (state) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final todo = args is String
              ? state.todos.where((item) => item.id == args).firstOrNull
              : null;
          if (!_initialized) {
            _initialize(args, todo);
          }
          if (args is String && todo == null) {
            return const Center(child: Text('待办不存在'));
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                PageTitleBar(
                  title: _todoId == null ? '创建待办' : '待办详情',
                  trailing: _todoId == null
                      ? const SizedBox(width: 48)
                      : IconButton(
                          tooltip: '删除待办',
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline),
                        ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: SoftCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('基本信息'),
                          _TextFieldLine(
                            label: '标题',
                            controller: _titleController,
                            hintText: '请输入标题',
                          ),
                          _TextFieldLine(
                            label: '内容',
                            controller: _contentController,
                            hintText: '请输入内容',
                            maxLines: 3,
                          ),
                          _TextFieldLine(
                            label: '地点',
                            controller: _locationController,
                            hintText: '请输入地点',
                          ),
                          const Divider(height: 28),
                          const _SectionTitle('待办种类'),
                          for (final kind in TodoKind.values)
                            _TypeOption(
                              label: todoKindLabel(kind),
                              selected: _kind == kind,
                              onTap: () => _selectKind(kind),
                            ),
                          if (_kind == TodoKind.duration)
                            _ActionLine(
                              label: '持续时间',
                              value:
                                  '起：${_startAt == null ? '00:00' : formatTime(_startAt!)} - 止：${_endAt == null ? '00:00' : formatTime(_endAt!)}',
                              onTap: _pickDuration,
                            ),
                          if (_kind == TodoKind.deadline)
                            _ActionLine(
                              label: 'DDL',
                              value: _deadlineAt == null
                                  ? '00:00'
                                  : formatTime(_deadlineAt!),
                              onTap: _pickDeadline,
                            ),
                          const Divider(height: 28),
                          const _SectionTitle('重要程度'),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _priority,
                                  min: 0,
                                  max: 5,
                                  divisions: 10,
                                  label: _priority.toStringAsFixed(1),
                                  onChanged: (value) =>
                                      setState(() => _priority = value),
                                ),
                              ),
                              _Stars(value: _priority),
                            ],
                          ),
                          const Divider(height: 28),
                          const _SectionTitle('Tag'),
                          InkWell(
                            onTap: () => _pickTags(state.tags),
                            borderRadius: BorderRadius.circular(
                              AppRadii.control,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.control,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                _tags.isEmpty ? '点击选择 Tag' : _tags.join('  '),
                                style: TextStyle(
                                  color: _tags.isEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 28),
                          _ActionLine(
                            label: '重复设置',
                            value: repeatRuleLabel(_repeatRule),
                            onTap: _pickRepeatRule,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('save-todo-detail-button'),
                  onPressed: _save,
                  child: Text(_todoId == null ? '创建待办' : '保存修改'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _initialize(Object? args, TodoItem? todo) {
    _initialized = true;
    if (todo != null) {
      _todoId = todo.id;
      _titleController.text = todo.title;
      _contentController.text = todo.content;
      _locationController.text = todo.location;
      _kind = todo.kind;
      _startAt = todo.startAt;
      _endAt = todo.endAt;
      _deadlineAt = todo.deadlineAt;
      _priority = todo.priority;
      _tags = List<String>.from(todo.tags);
      _repeatRule = todo.repeatRule;
      return;
    }
    if (args is TodoDraft) {
      _titleController.text = args.title;
      _contentController.text = args.content;
      _locationController.text = args.location;
      _kind = args.kind;
      _startAt = args.startAt;
      _endAt = args.endAt;
      _deadlineAt = args.deadlineAt;
      _priority = args.priority;
      _tags = List<String>.from(args.tags);
      _repeatRule = args.repeatRule;
    }
  }

  void _selectKind(TodoKind value) {
    setState(() {
      _kind = value;
      if (value == TodoKind.normal) {
        _startAt = null;
        _endAt = null;
        _deadlineAt = null;
      } else if (value == TodoKind.duration) {
        _deadlineAt = null;
        _startAt ??= DateTime(2026, 6, 19, 18);
        _endAt ??= DateTime(2026, 6, 19, 19, 30);
      } else {
        _startAt = null;
        _endAt = null;
        _deadlineAt ??= DateTime(2026, 6, 19, 23, 59);
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写标题')));
      return;
    }
    if (_kind == TodoKind.duration && (_startAt == null || _endAt == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择持续时间')));
      return;
    }
    if (_kind == TodoKind.deadline && _deadlineAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择 DDL')));
      return;
    }

    final notifier = ref.read(todosControllerProvider.notifier);
    if (_todoId == null) {
      await notifier.create(
        TodoDraft(
          title: title,
          content: _contentController.text,
          location: _locationController.text,
          kind: _kind,
          startAt: _startAt,
          endAt: _endAt,
          deadlineAt: _deadlineAt,
          priority: _priority,
          tags: _tags,
          repeatRule: _repeatRule,
        ),
      );
    } else {
      await notifier.updateTodo(
        _todoId!,
        TodoPatch(
          title: title,
          content: _contentController.text,
          location: _locationController.text,
          kind: _kind,
          startAt: _startAt,
          endAt: _endAt,
          deadlineAt: _deadlineAt,
          priority: _priority,
          tags: _tags,
          repeatRule: _repeatRule,
          clearDuration: _kind != TodoKind.duration,
          clearDeadline: _kind != TodoKind.deadline,
        ),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('是否确定删除待办？'),
        content: const Text('删除后无法恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && _todoId != null) {
      await ref.read(todosControllerProvider.notifier).delete(_todoId!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pickDuration() async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _startAt ?? DateTime(2026, 6, 19, 18),
      ),
    );
    if (start == null || !mounted) {
      return;
    }
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _endAt ?? DateTime(2026, 6, 19, 19, 30),
      ),
    );
    if (end == null) {
      return;
    }
    final date = DateTime(2026, 6, 19);
    final startAt = DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
    );
    var endAt = DateTime(date.year, date.month, date.day, end.hour, end.minute);
    if (!endAt.isAfter(startAt)) {
      endAt = startAt.add(const Duration(minutes: 30));
    }
    setState(() {
      _startAt = startAt;
      _endAt = endAt;
    });
  }

  Future<void> _pickDeadline() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _deadlineAt ?? DateTime(2026, 6, 19, 23, 59),
      ),
    );
    if (time == null) {
      return;
    }
    setState(() {
      _deadlineAt = DateTime(2026, 6, 19, time.hour, time.minute);
    });
  }

  Future<void> _pickTags(List<String> allTags) async {
    final selected = Set<String>.from(_tags);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '选择 Tag',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '新增 Tag',
                      onPressed: () async {
                        final added = await _addTagDialog();
                        if (added != null) {
                          selected.add(added);
                          setSheetState(() {});
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final tag in allTags)
                      TodoChip(
                        label: tag,
                        selected: selected.contains(tag),
                        onTap: () {
                          setSheetState(() {
                            selected.contains(tag)
                                ? selected.remove(tag)
                                : selected.add(tag);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (result != null) {
      setState(() => _tags = result.toList());
    }
  }

  Future<String?> _addTagDialog() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('请输入 Tag 名称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入 Tag 名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (tag == null || tag.isEmpty) {
      return null;
    }
    return ref.read(todosControllerProvider.notifier).addTag(tag);
  }

  Future<void> _pickRepeatRule() async {
    final rule = await showDialog<RepeatRule>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('重复设置'),
        children: [
          for (final rule in RepeatRule.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(rule),
              child: Text(repeatRuleLabel(rule)),
            ),
        ],
      ),
    );
    if (rule != null) {
      setState(() => _repeatRule = rule);
    }
  }
}

class _TextFieldLine extends StatelessWidget {
  const _TextFieldLine({
    required this.label,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hintText),
      ),
    );
  }
}

class _ActionLine extends StatelessWidget {
  const _ActionLine({
    required this.label,
    required this.value,
    required this.onTap,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: AppColors.textSecondary)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.accent : Colors.white,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : null,
        ),
        title: Text(label),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star
                : value >= i - 0.5
                ? Icons.star_half
                : Icons.star_border,
            size: 20,
            color: const Color(0xFFF59E0B),
          ),
      ],
    );
  }
}
