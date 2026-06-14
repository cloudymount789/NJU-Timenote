import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_bottom_input_bar.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/create_todo_sheet.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/right_sidebar_shell.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/todo.dart';
import '../../data/repositories/app_repositories.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  TodoFilter _filter = const TodoFilter();
  Future<List<TodoItem>>? _future;
  var _didLoad = false;
  var _batchMode = false;
  var _isSmartSortEnabled = false;
  final _selectedIds = <String>{};
  AppRepositories? _repositories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    final repositories = AppScope.repositoriesOf(context);
    _repositories = repositories;
    repositories.changes.addListener(_handleDataChanged);
    _didLoad = true;
    _future = _load();
  }

  @override
  void dispose() {
    _repositories?.changes.removeListener(_handleDataChanged);
    super.dispose();
  }

  void _handleDataChanged() {
    if (mounted) {
      setState(() {
        _future = _load();
      });
    }
  }

  Future<List<TodoItem>> _load() {
    return AppScope.repositoriesOf(context).todos.getTodos(_filter);
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    await future.catchError((_) => <TodoItem>[]);
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
    if (mounted) {
      await _refresh();
    }
  }

  Future<void> _openCreateDetail() async {
    await Navigator.of(context).pushNamed(
      AppRoutes.todoDetail,
      arguments: const TodoDetailRouteArgs(isCreate: true),
    );
    if (mounted) {
      await _refresh();
    }
  }

  Future<void> _complete(TodoItem todo) async {
    try {
      await AppScope.repositoriesOf(
        context,
      ).todos.toggleTodoCompletion(todo.id);
      await _refresh();
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
      await _refresh();
    }
  }

  bool get _isFilterActive {
    const initial = TodoFilter();
    return _filter.date != null ||
        _filter.kinds.length != initial.kinds.length ||
        !_filter.kinds.every(initial.kinds.contains) ||
        _filter.statuses.length != initial.statuses.length ||
        !_filter.statuses.every(initial.statuses.contains) ||
        _filter.tags.isNotEmpty;
  }

  Future<void> _toggleSmartSort() async {
    final repo = AppScope.repositoriesOf(context).todos;
    if (_isSmartSortEnabled) {
      final todos = await (_future ?? Future.value(const <TodoItem>[]));
      await repo.reorderTodos(todos.map((todo) => todo.id).toList());
      if (!mounted) {
        return;
      }
      setState(() {
        _isSmartSortEnabled = false;
      });
      await _refresh();
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '启用智能排序？',
      message: '这将覆盖现有手动排序，并按重要程度、截止/开始时间等重新排列待办。',
      confirmText: '排序',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await repo.smartSortTodos();
    if (mounted) {
      setState(() {
        _isSmartSortEnabled = true;
      });
      await _refresh();
    }
  }

  Future<void> _reorderVisible(int oldIndex, int newIndex) async {
    final repo = AppScope.repositoriesOf(context).todos;
    final todos = await (_future ?? Future.value(const <TodoItem>[]));
    final ordered = [...todos];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);
    setState(() {
      _isSmartSortEnabled = false;
      _future = Future.value(ordered);
    });
    await repo.reorderTodos(ordered.map((todo) => todo.id).toList());
    if (mounted) {
      await _refresh();
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
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            AppHeader(
              title: '待办',
              subtitle: _batchMode ? '批量操作' : null,
              onBack: _goHome,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_batchMode)
                    TextButton(
                      onPressed: () async {
                        if (_selectedIds.isNotEmpty) {
                          setState(_selectedIds.clear);
                          return;
                        }
                        final todos =
                            await (_future ?? Future.value(const <TodoItem>[]));
                        setState(() {
                          _selectedIds.addAll(todos.map((e) => e.id));
                        });
                      },
                      child: Text(_selectedIds.isEmpty ? '全选' : '取消选中'),
                    )
                  else ...[
                    AppIconButton(
                      icon: Icons.checklist,
                      tooltip: '批量操作',
                      onPressed: () => setState(() => _batchMode = true),
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: Icons.filter_alt_outlined,
                      tooltip: '筛选',
                      onPressed: _openFilter,
                      iconColor: _isFilterActive
                          ? AppColors.primary
                          : AppColors.ink,
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: Icons.add,
                      tooltip: '添加待办',
                      onPressed: _openCreateDetail,
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
                    onReorder: _reorderVisible,
                    onSmartSort: _toggleSmartSort,
                    isSmartSortEnabled: _isSmartSortEnabled,
                    onRefresh: _refresh,
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
                onInputTap: () async {
                  final created = await showCreateTodoSheet(
                    context,
                    navigateToTodosOnSubmit: false,
                    onTodosChanged: _refresh,
                  );
                  if (created == true && mounted) {
                    await _refresh();
                  }
                },
                onSearchTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.todoSearch),
                onQuickPickTap: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.nextThing);
                  if (mounted) {
                    await _refresh();
                  }
                },
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
    required this.onReorder,
    required this.onSmartSort,
    required this.isSmartSortEnabled,
    required this.onRefresh,
  });

  final Future<List<TodoItem>> future;
  final bool batchMode;
  final Set<String> selectedIds;
  final ValueChanged<TodoItem> onTap;
  final ValueChanged<TodoItem> onComplete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onSmartSort;
  final bool isSmartSortEnabled;
  final Future<void> Function() onRefresh;

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
            return Column(
              children: [
                if (!batchMode)
                  _SmartSortHeader(
                    enabled: isSmartSortEnabled,
                    onPressed: onSmartSort,
                  ),
                const Expanded(child: LoadingState()),
              ],
            );
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                if (!batchMode)
                  _SmartSortHeader(
                    enabled: isSmartSortEnabled,
                    onPressed: onSmartSort,
                  ),
                Expanded(child: ErrorState(message: '${snapshot.error}')),
              ],
            );
          }
          final todos = snapshot.data ?? const [];
          if (todos.isEmpty) {
            return Column(
              children: [
                if (!batchMode)
                  _SmartSortHeader(
                    enabled: isSmartSortEnabled,
                    onPressed: onSmartSort,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 160),
                        Center(
                          child: EmptyState(
                            title: '暂无待办',
                            message: '可以从底部输入栏或新建详情页添加。',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          var openIndex = 0;
          if (batchMode) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 10, 18, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '长按左侧图标可拖拽调整顺序',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 96),
                    buildDefaultDragHandles: false,
                    itemCount: todos.length,
                    onReorderItem: onReorder,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final number = todo.status == TodoStatus.open
                          ? ++openIndex
                          : null;
                      return _TodoRow(
                        key: ValueKey(todo.id),
                        todo: todo,
                        index: index,
                        number: number,
                        batchMode: batchMode,
                        selected: selectedIds.contains(todo.id),
                        onTap: () => onTap(todo),
                        onComplete: () => onComplete(todo),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _SmartSortHeader(
                enabled: isSmartSortEnabled,
                onPressed: onSmartSort,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 4, 8, 8),
                    itemCount: todos.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 54),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final number = todo.status == TodoStatus.open
                          ? ++openIndex
                          : null;
                      return _TodoRow(
                        todo: todo,
                        index: index,
                        number: number,
                        batchMode: batchMode,
                        selected: selectedIds.contains(todo.id),
                        onTap: () => onTap(todo),
                        onComplete: () => onComplete(todo),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SmartSortHeader extends StatelessWidget {
  const _SmartSortHeader({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  enabled ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: enabled ? AppColors.primary : AppColors.subtle,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  '智能排序',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.todo,
    required this.index,
    required this.number,
    required this.batchMode,
    required this.selected,
    required this.onTap,
    required this.onComplete,
    super.key,
  });

  final TodoItem todo;
  final int index;
  final int? number;
  final bool batchMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final done = todo.status == TodoStatus.done;
    final overdueDeadline =
        !done &&
        todo.kind == TodoKind.deadline &&
        todo.deadlineAt != null &&
        !todo.deadlineAt!.isAfter(AppScope.clockOf(context).now());
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: batchMode
                  ? ReorderableDelayedDragStartListener(
                      index: index,
                      child: const Icon(
                        Icons.drag_handle,
                        color: AppColors.primary,
                      ),
                    )
                  : number == null
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
                    todoListMetaText(todo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: overdueDeadline
                          ? AppColors.danger
                          : done
                          ? AppColors.subtle
                          : AppColors.muted,
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
              const SizedBox(
                width: 48,
                child: Center(
                  child: Icon(Icons.timelapse, color: AppColors.subtle),
                ),
              )
            else
              IconButton(
                tooltip: done ? '取消完成' : '完成',
                onPressed: onComplete,
                icon: Icon(
                  done ? Icons.undo_outlined : Icons.check_circle_outline,
                ),
                color: done ? AppColors.muted : AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

String todoListMetaText(TodoItem todo) {
  if (todo.isRecurring) {
    return switch (todo.kind) {
      TodoKind.duration => _repeatDurationMeta(todo),
      TodoKind.deadline => _repeatDeadlineMeta(todo),
      TodoKind.normal => '重复 普通待办',
    };
  }
  return switch (todo.kind) {
    TodoKind.duration => _formatRange(todo.startAt, todo.endAt),
    TodoKind.deadline => 'DDL: ${_formatDateTime(todo.deadlineAt)}',
    TodoKind.normal => todo.tags.isEmpty ? '普通待办' : todo.tags.join(' · '),
  };
}

String _repeatDeadlineMeta(TodoItem todo) {
  final deadline = todo.deadlineAt;
  if (deadline == null) {
    return '重复 DDL：未设置';
  }
  final time = _formatTime(deadline);
  return switch (todo.repeatRule) {
    RepeatRule.once => 'DDL: ${_formatDateTime(deadline)}',
    RepeatRule.daily => '重复 DDL：每天 $time',
    RepeatRule.weekly => '重复 DDL：每周 ${_weekday(deadline)} $time',
    RepeatRule.biweekly => '重复 DDL：每两周 ${_weekday(deadline)} $time',
  };
}

String _repeatDurationMeta(TodoItem todo) {
  final start = todo.startAt;
  final end = todo.endAt;
  if (start == null || end == null) {
    return '重复 未设置';
  }
  final range = '${_formatTime(start)} - ${_formatTime(end)}';
  return switch (todo.repeatRule) {
    RepeatRule.once => _formatRange(start, end),
    RepeatRule.daily => '重复 每天 $range',
    RepeatRule.weekly => '重复 每${_weekday(start)} $range',
    RepeatRule.biweekly => '重复 每两周 ${_weekday(start)} $range',
  };
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '未设置';
  }
  return '${value.month}.${value.day} ${_weekday(value)} ${_formatTime(value)}';
}

String _formatRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return '未设置';
  }
  final startText = _formatDateTime(start);
  if (_sameDay(start, end)) {
    return '$startText-${_formatTime(end)}';
  }
  return '$startText - ${_formatDateTime(end)}';
}

String _formatTime(DateTime value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _weekday(DateTime value) {
  return const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][value.weekday - 1];
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
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
  Future<List<String>>? _tagsFuture;
  var _didLoadTags = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadTags) {
      return;
    }
    _didLoadTags = true;
    _tagsFuture = AppScope.repositoriesOf(context).tags.getTags();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          GestureDetector(
            onTap: () {},
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
                        _filter.date == null
                            ? '选择日期'
                            : _dateText(_filter.date!),
                      ),
                      selected: _filter.date != null,
                      onSelected: (_) async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _filter.date ?? AppScope.clockOf(context).now(),
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
                          label: Text(
                            status == TodoStatus.open ? '未完成' : '已完成',
                          ),
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
                      future: _tagsFuture ?? Future.value(const <String>[]),
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
