import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';

class GoalSplitSetupScreen extends StatefulWidget {
  const GoalSplitSetupScreen({super.key});

  @override
  State<GoalSplitSetupScreen> createState() => _GoalSplitSetupScreenState();
}

class _GoalSplitSetupScreenState extends State<GoalSplitSetupScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _deadline = DateTime(2026, 6, 25, 23, 59);
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      final initial = ModalRoute.of(context)?.settings.arguments as String?;
      _titleController.text = initial?.trim().isNotEmpty == true
          ? initial!.trim()
          : '高数期末复习';
    }

    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const PageTitleBar(title: '大目标拆分'),
            const _StepIndicator('步骤 1/3 · 设定大目标'),
            Expanded(
              child: SoftCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: '大目标名称'),
                      onChanged: (_) => setState(() {}),
                    ),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        hintText: '选填，如复习范围、目标分数等',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('最终截止 DDL'),
                      trailing: Text(formatDateTimeShort(_deadline)),
                      onTap: _pickDeadline,
                    ),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: _titleController.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(context).pushNamed(
                      AppRoutes.goalSplitBreakdown,
                      arguments: GoalSplitDraft(
                        title: _titleController.text.trim(),
                        note: _noteController.text,
                        finalDeadline: _deadline,
                        subtasks: _defaultSubtasks(),
                      ),
                    ),
              child: const Text('下一步'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2026, 6, 9),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  List<GoalSubtaskDraft> _defaultSubtasks() {
    return [
      GoalSubtaskDraft(title: '整理第一章笔记', plannedDate: DateTime(2026, 6, 19)),
      GoalSubtaskDraft(title: '完成习题 1-20', plannedDate: DateTime(2026, 6, 20)),
      GoalSubtaskDraft(title: '模拟卷 A', plannedDate: DateTime(2026, 6, 21)),
      GoalSubtaskDraft(title: '错题回顾', plannedDate: DateTime(2026, 6, 22)),
    ];
  }
}

class GoalSplitBreakdownScreen extends StatefulWidget {
  const GoalSplitBreakdownScreen({super.key});

  @override
  State<GoalSplitBreakdownScreen> createState() =>
      _GoalSplitBreakdownScreenState();
}

class _GoalSplitBreakdownScreenState extends State<GoalSplitBreakdownScreen> {
  late GoalSplitDraft _draft;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      _draft = ModalRoute.of(context)!.settings.arguments! as GoalSplitDraft;
    }

    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const PageTitleBar(title: '拆分小目标'),
            const _StepIndicator('步骤 2/3 · 拆分小目标'),
            Expanded(
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _draft.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '最终 DDL · ${formatDateTimeShort(_draft.finalDeadline)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '小目标列表',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var i = 0; i < _draft.subtasks.length; i++)
                            _SubtaskTile(
                              subtask: _draft.subtasks[i],
                              onDate: () => _pickSubtaskDate(i),
                              onDelete: () => setState(() {
                                final next = List<GoalSubtaskDraft>.from(
                                  _draft.subtasks,
                                )..removeAt(i);
                                _draft = _draft.copyWith(subtasks: next);
                              }),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _addSubtask,
                      icon: const Icon(Icons.add),
                      label: const Text('添加小目标'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _draft.subtasks.isEmpty
                  ? null
                  : () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.goalSplitReview, arguments: _draft),
              child: const Text('预览拆分'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSubtaskDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.subtasks[index].plannedDate,
      firstDate: DateTime(2026, 6, 9),
      lastDate: _draft.finalDeadline,
    );
    if (picked != null) {
      setState(() {
        final next = List<GoalSubtaskDraft>.from(_draft.subtasks);
        next[index] = GoalSubtaskDraft(
          title: next[index].title,
          plannedDate: picked,
        );
        _draft = _draft.copyWith(subtasks: next);
      });
    }
  }

  Future<void> _addSubtask() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加小目标'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '小目标名称'),
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
    if (title == null || title.isEmpty) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(
        subtasks: [
          ..._draft.subtasks,
          GoalSubtaskDraft(title: title, plannedDate: DateTime(2026, 6, 23)),
        ],
      );
    });
  }
}

class GoalSplitReviewScreen extends ConsumerWidget {
  const GoalSplitReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ModalRoute.of(context)!.settings.arguments! as GoalSplitDraft;
    final grouped = <String, List<GoalSubtaskDraft>>{};
    for (final subtask in draft.subtasks) {
      grouped
          .putIfAbsent(formatMonthDay(subtask.plannedDate), () => [])
          .add(subtask);
    }

    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const PageTitleBar(title: '大目标拆分'),
            const _StepIndicator('步骤 3/3 · 确认生成'),
            Expanded(
              child: SoftCard(
                child: ListView(
                  children: [
                    Text(
                      draft.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '最终 DDL · ${formatDateTimeShort(draft.finalDeadline)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '拆分时间线',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    for (final entry in grouped.entries) ...[
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      for (final subtask in entry.value)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.circle, size: 9),
                          title: Text(subtask.title),
                        ),
                    ],
                    Text(
                      '共 ${draft.subtasks.length} 条小目标，将批量创建为有截止时间的待办',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('confirm-goal-split-button'),
              onPressed: () => _confirmGenerate(context, ref, draft),
              child: const Text('确认生成'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmGenerate(
    BuildContext context,
    WidgetRef ref,
    GoalSplitDraft draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认生成 ${draft.subtasks.length} 条待办？'),
        content: const Text('生成后可在待办详情中单独修改'),
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
    if (confirmed == true && context.mounted) {
      await ref.read(todosControllerProvider.notifier).createGoalSplit(draft);
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.todos,
          (route) => route.settings.name == AppRoutes.home,
        );
      }
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: AppColors.accent)),
      ),
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  const _SubtaskTile({
    required this.subtask,
    required this.onDate,
    required this.onDelete,
  });

  final GoalSubtaskDraft subtask;
  final VoidCallback onDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(subtask.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionChip(
            label: Text(formatMonthDay(subtask.plannedDate)),
            onPressed: onDate,
          ),
          IconButton(
            tooltip: '删除小目标',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
