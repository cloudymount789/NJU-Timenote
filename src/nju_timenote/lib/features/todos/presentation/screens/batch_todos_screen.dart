import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/widgets/app_shell.dart';
import '../widgets/todo_widgets.dart';

class BatchTodosScreen extends ConsumerStatefulWidget {
  const BatchTodosScreen({super.key});

  @override
  ConsumerState<BatchTodosScreen> createState() => _BatchTodosScreenState();
}

class _BatchTodosScreenState extends ConsumerState<BatchTodosScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosControllerProvider);

    return AppGradientScaffold(
      child: todosState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('待办加载失败：$error')),
        data: (state) {
          final selectable = state.todos.where((todo) => !todo.isDone).toList();
          final allSelected =
              selectable.isNotEmpty &&
              selectable.every((todo) => _selectedIds.contains(todo.id));
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                PageTitleBar(
                  title: '批量操作',
                  trailing: TextButton(
                    key: const Key('batch-select-all-button'),
                    onPressed: () {
                      setState(() {
                        if (allSelected) {
                          _selectedIds.clear();
                        } else {
                          _selectedIds
                            ..clear()
                            ..addAll(selectable.map((todo) => todo.id));
                        }
                      });
                    },
                    child: Text(allSelected ? '取消全选' : '全选'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: TodoListCard(
                      todos: state.todos,
                      selectionMode: true,
                      selectedIds: _selectedIds,
                      onTap: (_) {},
                      onSelect: (todo) {
                        if (todo.isDone) {
                          return;
                        }
                        setState(() {
                          _selectedIds.contains(todo.id)
                              ? _selectedIds.remove(todo.id)
                              : _selectedIds.add(todo.id);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _BatchActionBar(
                  enabled: _selectedIds.isNotEmpty,
                  onComplete: () => _confirmComplete(context),
                  onDelete: () => _confirmDelete(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await _showConfirm(
      context,
      title: '是否确认删除？',
      subtitle: '删除后无法恢复',
    );
    if (confirmed && context.mounted) {
      await ref
          .read(todosControllerProvider.notifier)
          .batchDelete(_selectedIds);
      setState(_selectedIds.clear);
    }
  }

  Future<void> _confirmComplete(BuildContext context) async {
    final confirmed = await _showConfirm(
      context,
      title: '是否确认批量完成？',
      subtitle: '这将不会将有持续时间的待办变为已完成',
    );
    if (confirmed && context.mounted) {
      await ref
          .read(todosControllerProvider.notifier)
          .batchComplete(_selectedIds);
      setState(_selectedIds.clear);
    }
  }

  Future<bool> _showConfirm(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
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
    return result ?? false;
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.enabled,
    required this.onComplete,
    required this.onDelete,
  });

  final bool enabled;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: enabled ? onComplete : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(126, 46),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.done_all),
            label: const Text('批量完成'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: enabled ? onDelete : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('删除'),
            ),
          ),
        ],
      ),
    );
  }
}
