import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/todo.dart';

class TodoSearchPage extends StatefulWidget {
  const TodoSearchPage({super.key});

  @override
  State<TodoSearchPage> createState() => _TodoSearchPageState();
}

class _TodoSearchPageState extends State<TodoSearchPage> {
  static final List<String> _history = [];
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Future<List<TodoItem>>? _future;
  String _query = '';

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

  void _search([String? value]) {
    final query = (value ?? _controller.text).trim();
    setState(() {
      _query = query;
      _future = query.isEmpty
          ? Future.value(const <TodoItem>[])
          : AppScope.repositoriesOf(context).todos.searchTodos(query);
      if (query.isNotEmpty) {
        _history.remove(query);
        _history.insert(0, query);
        if (_history.length > 8) {
          _history.removeRange(8, _history.length);
        }
      }
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '清空历史记录',
      message: '确认清空全部搜索历史？',
      confirmText: '清空',
    );
    if (confirmed == true && mounted) {
      setState(_history.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            AppHeader(
              title: '搜索',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '搜索待办',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: '清空',
                              onPressed: () {
                                _controller.clear();
                                _search('');
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _search, child: const Text('搜索')),
              ],
            ),
            const SizedBox(height: 18),
            if (_future == null)
              _HistoryView(
                history: _history,
                onPick: _pickHistory,
                onClear: _clearHistory,
              ),
            if (_future != null)
              Expanded(
                child: FutureBuilder<List<TodoItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingState();
                    }
                    if (snapshot.hasError) {
                      return ErrorState(message: '${snapshot.error}');
                    }
                    final results = snapshot.data ?? const [];
                    if (_query.isEmpty) {
                      return _HistoryView(
                        history: _history,
                        onPick: _pickHistory,
                        onClear: _clearHistory,
                      );
                    }
                    if (results.isEmpty) {
                      return const Center(child: EmptyState(title: '没有匹配的待办'));
                    }
                    return _SearchResults(results: results);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _pickHistory(String query) {
    _controller.text = query;
    _search(query);
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.history,
    required this.onPick,
    required this.onClear,
  });

  final List<String> history;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Expanded(
        child: Center(child: EmptyState(title: '暂无搜索历史')),
      );
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('历史记录', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: onClear, child: const Text('清空')),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history
                .map(
                  (query) => ActionChip(
                    label: Text(query),
                    onPressed: () => onPick(query),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results});

  final List<TodoItem> results;

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
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final todo = results[index];
          return ListTile(
            title: Text(
              todo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              todo.tags.isEmpty ? todo.location : todo.tags.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.todoDetail,
              arguments: TodoDetailRouteArgs(todoId: todo.id),
            ),
          );
        },
      ),
    );
  }
}
