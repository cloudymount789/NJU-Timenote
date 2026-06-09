import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';

class TodoBottomInputBar extends StatelessWidget {
  const TodoBottomInputBar({
    required this.onQuickPick,
    required this.onInput,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onQuickPick;
  final VoidCallback onInput;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5F8FF),
                  Color(0xFFF0F4FF),
                  Color(0xFFF5F0FF),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: IconButton(
              tooltip: '快速挑选',
              onPressed: onQuickPick,
              icon: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Color(0xFF6B9FFF),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: onInput,
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '智能一句话添加待办...',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          IconButton.filled(
            tooltip: '待办搜索',
            onPressed: onSearch,
            style: IconButton.styleFrom(
              fixedSize: const Size(40, 40),
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
            ),
            icon: const Icon(Icons.search, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class TodoListCard extends StatelessWidget {
  const TodoListCard({
    required this.todos,
    required this.onTap,
    this.onComplete,
    this.selectionMode = false,
    this.selectedIds = const {},
    this.onSelect,
    super.key,
  });

  final List<TodoItem> todos;
  final ValueChanged<TodoItem> onTap;
  final ValueChanged<TodoItem>? onComplete;
  final bool selectionMode;
  final Set<String> selectedIds;
  final ValueChanged<TodoItem>? onSelect;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const SoftCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              '暂无待办，先添加一件小事吧',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    var openIndex = 0;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < todos.length; i++) ...[
            Builder(
              builder: (context) {
                final todo = todos[i];
                final displayIndex = todo.isDone ? null : ++openIndex;
                return TodoListRow(
                  todo: todo,
                  index: displayIndex,
                  onTap: () =>
                      selectionMode ? onSelect?.call(todo) : onTap(todo),
                  onComplete: onComplete == null
                      ? null
                      : () => onComplete?.call(todo),
                  selectionMode: selectionMode,
                  selected: selectedIds.contains(todo.id),
                );
              },
            ),
            if (i != todos.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class TodoListRow extends StatelessWidget {
  const TodoListRow({
    required this.todo,
    required this.index,
    required this.onTap,
    this.onComplete,
    this.selectionMode = false,
    this.selected = false,
    super.key,
  });

  final TodoItem todo;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: todo.isDone ? AppColors.textMuted : AppColors.textPrimary,
      decoration: todo.isDone ? TextDecoration.lineThrough : null,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                index?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                todo.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
            const SizedBox(width: 12),
            if (selectionMode)
              _SelectionDot(selected: selected)
            else
              _TodoRight(todo: todo, onComplete: onComplete),
          ],
        ),
      ),
    );
  }
}

class _TodoRight extends StatelessWidget {
  const _TodoRight({required this.todo, this.onComplete});

  final TodoItem todo;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    if (todo.kind == TodoKind.duration && todo.startAt != null) {
      return Text(
        formatTodoDuration(todo.startAt!, todo.endAt ?? todo.startAt!),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: todo.isDone ? null : onComplete,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            minimumSize: const Size(58, 32),
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
          ),
          child: Text(todo.isDone ? '已完成' : '完成'),
        ),
        if (todo.deadlineAt != null)
          Text(
            'DDL: ${formatDateTimeShort(todo.deadlineAt!)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
      ],
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

class TodoChip extends StatelessWidget {
  const TodoChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFFEAF2FF),
      side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }
}

String todoKindLabel(TodoKind kind) {
  return switch (kind) {
    TodoKind.duration => '有持续时间',
    TodoKind.deadline => '有截止时间',
    TodoKind.normal => '普通',
  };
}

String repeatRuleLabel(RepeatRule rule) {
  return switch (rule) {
    RepeatRule.once => '仅一次',
    RepeatRule.daily => '每天',
    RepeatRule.weekly => '每周',
  };
}
