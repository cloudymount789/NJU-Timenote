import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_bottom_input_bar.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/create_todo_sheet.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/right_sidebar_shell.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({required this.onlyDeadline, super.key});

  final bool onlyDeadline;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late TodoFilter _filter = TodoFilter(onlyDeadline: widget.onlyDeadline);
  Future<List<TodoItem>>? _future;
  var _didLoad = false;
  var _batchMode = false;
  final _selectedIds = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _future = _load();
  }

  Future<List<TodoItem>> _load() {
    return AppScope.repositoriesOf(context).todos.getTodos(_filter);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _goHome() {
    if (_batchMode) {
      setState(() {
        _batchMode = false;
        _selectedIds.clear();
      });
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _openDetail(TodoItem todo) async {
    if (_batchMode) {
      setState(() {
        _selectedIds.contains(todo.id)
            ? _selectedIds.remove(todo.id)
            : _selectedIds.add(todo.id);
      });
      return;
    }
    await Navigator.of(context).pushNamed(
      AppRoutes.todoDetail,
      arguments: TodoDetailRouteArgs(todoId: todo.id),
    );
    _refresh();
  }

  Future<void> _complete(TodoItem todo) async {
    try {
      await AppScope.repositoriesOf(context).todos.completeTodo(todo.id);
      _refresh();
    } catch (error) {
      _showMessage('$error');
    }
  }

  Future<void> _openFilter() async {
    final result = await showGeneralDialog<TodoFilter>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭筛选',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      pageBuilder: (context, _, _) {
        return _TodoFilterSidebar(initial: _filter);
      },
    );
    if (result != null) {
      setState(() {
        _filter = result;
        _future = _load();
      });
    } else {
      _refresh();
    }
  }

  Future<void> _batchComplete() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    final repo = AppScope.repositoriesOf(context).todos;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '批量完成',
      message: '确认完成所选待办？持续时间待办会被跳过。',
      confirmText: '完成',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await repo.batchComplete(_selectedIds.toList());
    if (!mounted) {
      return;
    }
    setState(() {
      _batchMode = false;
      _selectedIds.clear();
      _future = _load();
    });
  }

  Future<void> _batchDelete() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    final repo = AppScope.repositoriesOf(context).todos;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除待办',
      message: '确认删除所选待办？删除后当前本地列表中将不再显示。',
      confirmText: '删除',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await repo.batchDelete(_selectedIds.toList());
    if (!mounted) {
      return;
    }
    setState(() {
      _batchMode = false;
      _selectedIds.clear();
      _future = _load();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            AppHeader(
              title: widget.onlyDeadline ? 'DDL 提醒' : '待办',
              subtitle: _batchMode ? '批量操作' : null,
              onBack: _goHome,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_batchMode)
                    TextButton(
                      onPressed: () async {
                        final todos =
                            await (_future ?? Future.value(const <TodoItem>[]));
                        setState(() {
                          _selectedIds.length == todos.length
                              ? _selectedIds.clear()
                              : _selectedIds.addAll(todos.map((e) => e.id));
                        });
                      },
                      child: Text(_selectedIds.isEmpty ? '全选' : '取消全选'),
                    )
                  else ...[
                    AppIconButton(
                      icon: Icons.filter_alt_outlined,
                      tooltip: '筛选',
                      onPressed: _openFilter,
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: Icons.checklist,
                      tooltip: '批量操作',
                      onPressed: () => setState(() => _batchMode = true),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  _TodoListCard(
                    future: _future ?? Future.value(const <TodoItem>[]),
                    batchMode: _batchMode,
                    selectedIds: _selectedIds,
                    onTap: _openDetail,
                    onComplete: _complete,
                  ),
                  if (_batchMode)
                    Positioned(
                      left: 60,
                      right: 60,
                      bottom: 16,
                      child: _BatchActionBar(
                        onComplete: _batchComplete,
                        onDelete: _batchDelete,
                      ),
                    ),
                ],
              ),
            ),
            if (!_batchMode) ...[
              const SizedBox(height: 12),
              AppBottomInputBar(
                onInputTap: () => showCreateTodoSheet(context),
                onSearchTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.todoSearch),
                onQuickPickTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.nextThing),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodoListCard extends StatelessWidget {
  const _TodoListCard({
    required this.future,
    required this.batchMode,
    required this.selectedIds,
    required this.onTap,
    required this.onComplete,
  });

  final Future<List<TodoItem>> future;
  final bool batchMode;
  final Set<String> selectedIds;
  final ValueChanged<TodoItem> onTap;
  final ValueChanged<TodoItem> onComplete;

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
      child: FutureBuilder<List<TodoItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState();
          }
          if (snapshot.hasError) {
            return ErrorState(message: '${snapshot.error}');
          }
          final todos = snapshot.data ?? const [];
          if (todos.isEmpty) {
            return const Center(
              child: EmptyState(title: '暂无待办', message: '可以从底部输入栏或新建详情页添加。'),
            );
          }
          var openIndex = 0;
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(0, 8, 8, batchMode ? 96 : 8),
            itemCount: todos.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 54),
            itemBuilder: (context, index) {
              final todo = todos[index];
              final number = todo.status == TodoStatus.open
                  ? ++openIndex
                  : null;
              return _TodoRow(
                todo: todo,
                number: number,
                batchMode: batchMode,
                selected: selectedIds.contains(todo.id),
                onTap: () => onTap(todo),
                onComplete: () => onComplete(todo),
              );
            },
          );
        },
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.todo,
    required this.number,
    required this.batchMode,
    required this.selected,
    required this.onTap,
    required this.onComplete,
  });

  final TodoItem todo;
  final int? number;
  final bool batchMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final done = todo.status == TodoStatus.done;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: number == null
                  ? const SizedBox.shrink()
                  : Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: done ? AppColors.subtle : AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _meta(todo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: done ? AppColors.subtle : AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (batchMode)
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.subtle,
              )
            else if (todo.kind == TodoKind.duration)
              const Icon(Icons.timelapse, color: AppColors.subtle)
            else if (!done)
              IconButton(
                tooltip: '完成',
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline),
                color: AppColors.primary,
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  String _meta(TodoItem todo) {
    switch (todo.kind) {
      case TodoKind.duration:
        return '${_formatDateTime(todo.startAt)} - ${_formatDateTime(todo.endAt)}';
      case TodoKind.deadline:
        return 'DDL: ${_formatDateTime(todo.deadlineAt)}';
      case TodoKind.normal:
        return todo.tags.isEmpty ? '普通待办' : todo.tags.join(' · ');
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '未设置';
    }
    return '${value.month}.${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({required this.onComplete, required this.onDelete});

  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('完成'),
            ),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              label: const Text('删除'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoFilterSidebar extends StatefulWidget {
  const _TodoFilterSidebar({required this.initial});

  final TodoFilter initial;

  @override
  State<_TodoFilterSidebar> createState() => _TodoFilterSidebarState();
}

class _TodoFilterSidebarState extends State<_TodoFilterSidebar> {
  late TodoFilter _filter = widget.initial;
  late Future<List<String>> _tagsFuture;

  @override
  void initState() {
    super.initState();
    _tagsFuture = AppScope.repositoriesOf(context).tags.getTags();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: RightSidebarShell(
        title: '筛选',
        children: [
          _SidebarSection(
            title: '日期',
            children: [
              ChoiceChip(
                label: const Text('全部'),
                selected: _filter.date == null,
                onSelected: (_) => setState(
                  () => _filter = _filter.copyWith(
                    date: const PatchField.value(null),
                  ),
                ),
              ),
              ChoiceChip(
                label: Text(
                  _filter.date == null ? '选择日期' : _dateText(_filter.date!),
                ),
                selected: _filter.date != null,
                onSelected: (_) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _filter.date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(
                      () => _filter = _filter.copyWith(
                        date: PatchField.value(picked),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          _SidebarSection(
            title: '种类',
            children: TodoKind.values
                .map(
                  (kind) => FilterChip(
                    label: Text(_kindLabel(kind)),
                    selected: _filter.kinds.contains(kind),
                    onSelected: (_) => _toggleKind(kind),
                  ),
                )
                .toList(),
          ),
          _SidebarSection(
            title: '完成情况',
            children: TodoStatus.values
                .map(
                  (status) => FilterChip(
                    label: Text(status == TodoStatus.open ? '未完成' : '已完成'),
                    selected: _filter.statuses.contains(status),
                    onSelected: (_) => _toggleStatus(status),
                  ),
                )
                .toList(),
          ),
          _SidebarSection(
            title: 'Tag',
            children: [
              FutureBuilder<List<String>>(
                future: _tagsFuture,
                builder: (context, snapshot) {
                  final tags = snapshot.data ?? const [];
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: _filter.tags.contains(tag),
                            onSelected: (_) => _toggleTag(tag),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_filter),
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleKind(TodoKind kind) {
    final kinds = [..._filter.kinds];
    kinds.contains(kind) ? kinds.remove(kind) : kinds.add(kind);
    setState(() => _filter = _filter.copyWith(kinds: kinds));
  }

  void _toggleStatus(TodoStatus status) {
    final statuses = [..._filter.statuses];
    statuses.contains(status) ? statuses.remove(status) : statuses.add(status);
    setState(() => _filter = _filter.copyWith(statuses: statuses));
  }

  void _toggleTag(String tag) {
    final tags = [..._filter.tags];
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    setState(() => _filter = _filter.copyWith(tags: tags));
  }

  String _dateText(DateTime date) {
    return '${date.month}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

String _kindLabel(TodoKind kind) {
  return switch (kind) {
    TodoKind.duration => '有持续时间',
    TodoKind.deadline => '有截止时间',
    TodoKind.normal => '普通',
  };
}
