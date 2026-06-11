import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';
import '../widgets/todo_widgets.dart';

class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(todosControllerProvider);

    return AppGradientScaffold(
      child: todosState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('待办加载失败：$error')),
        data: (state) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              PageTitleBar(
                title: '待办',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('todos-batch-button'),
                      tooltip: '批量操作',
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.batchTodos),
                      icon: const Icon(Icons.checklist_rtl),
                    ),
                    IconButton(
                      key: const Key('todos-filter-button'),
                      tooltip: '筛选',
                      onPressed: () => _openFilter(context, ref, state),
                      icon: Icon(
                        state.filter.isActive
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.filter.isActive) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => ref
                        .read(todosControllerProvider.notifier)
                        .clearFilter(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('清除筛选'),
                  ),
                ),
              ] else
                const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: TodoListCard(
                    todos: state.todos,
                    onTap: (todo) => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.todoDetail, arguments: todo.id),
                    onComplete: (todo) => ref
                        .read(todosControllerProvider.notifier)
                        .complete(todo.id),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TodoBottomInputBar(
                onQuickPick: () =>
                    Navigator.of(context).pushNamed(AppRoutes.nextAction),
                onInput: () => showCreateTodoSheet(context, ref),
                onSearch: () =>
                    Navigator.of(context).pushNamed(AppRoutes.todoSearch),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilter(BuildContext context, WidgetRef ref, TodosState state) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭筛选',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: _FilterDrawer(initialState: state),
        );
      },
    );
  }
}

class _FilterDrawer extends ConsumerStatefulWidget {
  const _FilterDrawer({required this.initialState});

  final TodosState initialState;

  @override
  ConsumerState<_FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends ConsumerState<_FilterDrawer> {
  late TodoFilter _filter = widget.initialState.filter;

  @override
  Widget build(BuildContext context) {
    final tags = widget.initialState.tags;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 306,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 62, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(AppRadii.sheet),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('筛选', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _filter = const TodoFilter()),
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel('日期'),
            Wrap(
              spacing: 8,
              children: [
                TodoChip(
                  label: '全部',
                  selected: _filter.date == null,
                  onTap: () => setState(
                    () => _filter = _filter.copyWith(clearDate: true),
                  ),
                ),
                TodoChip(
                  label: _filter.date == null
                      ? formatMonthDay(DateTime.now())
                      : formatMonthDay(_filter.date!),
                  selected: _filter.date != null,
                  onTap: _pickDate,
                ),
              ],
            ),
            _SectionLabel('待办种类'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final kind in TodoKind.values)
                  TodoChip(
                    label: todoKindLabel(kind),
                    selected: _filter.kinds.contains(kind),
                    onTap: () => setState(() {
                      final next = Set<TodoKind>.from(_filter.kinds);
                      next.contains(kind) ? next.remove(kind) : next.add(kind);
                      _filter = _filter.copyWith(kinds: next);
                    }),
                  ),
              ],
            ),
            _SectionLabel('完成情况'),
            Wrap(
              spacing: 8,
              children: [
                TodoChip(
                  label: '未完成',
                  selected: _filter.statuses.contains(TodoStatus.open),
                  onTap: () => _toggleStatus(TodoStatus.open),
                ),
                TodoChip(
                  label: '已完成',
                  selected: _filter.statuses.contains(TodoStatus.done),
                  onTap: () => _toggleStatus(TodoStatus.done),
                ),
              ],
            ),
            _SectionLabel('Tag'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final tag in tags)
                  TodoChip(
                    label: tag,
                    selected: _filter.tags.contains(tag),
                    onTap: () => setState(() {
                      final next = Set<String>.from(_filter.tags);
                      next.contains(tag) ? next.remove(tag) : next.add(tag);
                      _filter = _filter.copyWith(tags: next);
                    }),
                  ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(todosControllerProvider.notifier)
                    .setFilter(_filter);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('应用筛选'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.date ?? DateTime.now(),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() => _filter = _filter.copyWith(date: picked));
    }
  }

  void _toggleStatus(TodoStatus status) {
    setState(() {
      final next = Set<TodoStatus>.from(_filter.statuses);
      next.contains(status) ? next.remove(status) : next.add(status);
      _filter = _filter.copyWith(statuses: next);
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

Future<void> showCreateTodoSheet(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final text = controller.text.trim();
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              6,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '创建待办',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '大目标拆分',
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.goalSplitSetup, arguments: text);
                      },
                      icon: const Icon(Icons.account_tree_outlined),
                    ),
                  ],
                ),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '用一句话，记录待办的内容，时间，地点，重要程度吧~',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.todoDetail,
                          arguments: const TodoDraft(title: ''),
                        );
                      },
                      icon: const Icon(Icons.edit_note),
                      label: const Text('手动创建待办'),
                    ),
                    const Spacer(),
                    IconButton.filled(
                      key: const Key('quick-create-todo-button'),
                      tooltip: '智能创建',
                      onPressed: text.isEmpty
                          ? null
                          : () async {
                              await ref
                                  .read(todosControllerProvider.notifier)
                                  .create(
                                    TodoDraft(
                                      title: text.length > 18
                                          ? text.substring(0, 18)
                                          : text,
                                      content: text,
                                      kind: TodoKind.deadline,
                                      deadlineAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 23, 59),
                                      priority: 4,
                                      tags: const ['学习'],
                                    ),
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.todos);
                              }
                            },
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
