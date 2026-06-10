import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';
import '../widgets/todo_widgets.dart';

class TodoSearchScreen extends ConsumerStatefulWidget {
  const TodoSearchScreen({super.key});

  @override
  ConsumerState<TodoSearchScreen> createState() => _TodoSearchScreenState();
}

class _TodoSearchScreenState extends ConsumerState<TodoSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<TodoItem>? _results;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosControllerProvider);
    return AppGradientScaffold(
      child: todosState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('搜索加载失败：$error')),
        data: (state) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageTitleBar(title: '待办搜索'),
              const SizedBox(height: 18),
              _SearchRow(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: () => setState(() {}),
                onClear: () {
                  _controller.clear();
                  setState(() => _results = null);
                },
                onSearch: _search,
              ),
              const SizedBox(height: 20),
              if (_results == null)
                _HistorySection(
                  history: state.searchHistory,
                  onPick: (keyword) {
                    _controller.text = keyword;
                    _search();
                  },
                  onClear: _clearHistory,
                )
              else ...[
                Text(
                  '共 ${_results!.length} 条结果',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: TodoListCard(
                      todos: _results!,
                      onTap: (todo) => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.todoDetail, arguments: todo.id),
                      onComplete: (todo) async {
                        await ref
                            .read(todosControllerProvider.notifier)
                            .complete(todo.id);
                        await _search();
                      },
                    ),
                  ),
                ),
                if (_results!.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        '没有找到匹配的待办',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _search() async {
    final results = await ref
        .read(todosControllerProvider.notifier)
        .search(_controller.text);
    if (mounted) {
      setState(() => _results = results);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('是否清空历史记录？'),
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
    if (confirmed == true) {
      await ref.read(todosControllerProvider.notifier).clearSearchHistory();
    }
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.onSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onClear;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: '搜索',
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '清空',
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 74,
          child: FilledButton(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              minimumSize: const Size(74, 52),
              padding: EdgeInsets.zero,
            ),
            child: const Text('搜索'),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.history,
    required this.onPick,
    required this.onClear,
  });

  final List<String> history;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('历史记录', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                tooltip: '清空历史记录',
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final item in history)
                ActionChip(label: Text(item), onPressed: () => onPick(item)),
            ],
          ),
        ],
      ),
    );
  }
}
