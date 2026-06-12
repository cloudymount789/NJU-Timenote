import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';

import 'app_feedback.dart';

Future<bool?> showCreateTodoSheet(
  BuildContext context, {
  String? initialText,
  bool navigateToTodosOnSubmit = true,
  VoidCallback? onTodosChanged,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => CreateTodoSheet(
      parentContext: context,
      initialText: initialText,
      navigateToTodosOnSubmit: navigateToTodosOnSubmit,
      onTodosChanged: onTodosChanged,
    ),
  );
}

class CreateTodoSheet extends StatefulWidget {
  const CreateTodoSheet({
    required this.parentContext,
    required this.navigateToTodosOnSubmit,
    this.initialText,
    this.onTodosChanged,
    super.key,
  });

  final BuildContext parentContext;
  final bool navigateToTodosOnSubmit;
  final String? initialText;
  final VoidCallback? onTodosChanged;

  @override
  State<CreateTodoSheet> createState() => _CreateTodoSheetState();
}

class _CreateTodoSheetState extends State<CreateTodoSheet> {
  final _controller = TextEditingController();
  var _submitting = false;

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText ?? '';
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openGoalSplit(String? title) async {
    final navigator = Navigator.of(widget.parentContext);
    Navigator.of(context).pop();
    final result = await navigator.pushNamed(
      AppRoutes.goalSplit,
      arguments: GoalSplitRouteArgs(initialTitle: title),
    );
    if (result is String && widget.parentContext.mounted) {
      await showCreateTodoSheet(
        widget.parentContext,
        initialText: result,
        navigateToTodosOnSubmit: widget.navigateToTodosOnSubmit,
        onTodosChanged: widget.onTodosChanged,
      );
    } else {
      widget.onTodosChanged?.call();
    }
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    final navigator = Navigator.of(widget.parentContext);
    try {
      await AppScope.repositoriesOf(
        widget.parentContext,
      ).quickTodos.createFromSentence(title);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
      widget.onTodosChanged?.call();
      if (widget.navigateToTodosOnSubmit) {
        await navigator.pushNamed(AppRoutes.todos);
      }
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, '创建失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '创建待办',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: '大目标拆分',
                    child: IconButton(
                      onPressed: () {
                        final title = _controller.text.trim();
                        _openGoalSplit(title.isEmpty ? null : title);
                      },
                      icon: const Icon(Icons.account_tree_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '用一句话，记录待办的内容，时间，地点，重要程度吧~',
                  hintStyle: const TextStyle(color: AppColors.subtle),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final navigator = Navigator.of(widget.parentContext);
                      Navigator.of(context).pop();
                      navigator
                          .pushNamed(
                            AppRoutes.todoDetail,
                            arguments: const TodoDetailRouteArgs(
                              isCreate: true,
                            ),
                          )
                          .then((changed) {
                            if (changed == true) {
                              widget.onTodosChanged?.call();
                            }
                          });
                    },
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('手动创建待办'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _hasText ? _submit : null,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.arrow_upward, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
