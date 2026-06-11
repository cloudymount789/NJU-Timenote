import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';

Future<void> showCreateTodoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (context) => const CreateTodoSheet(),
  );
}

class CreateTodoSheet extends StatefulWidget {
  const CreateTodoSheet({super.key});

  @override
  State<CreateTodoSheet> createState() => _CreateTodoSheetState();
}

class _CreateTodoSheetState extends State<CreateTodoSheet> {
  final TextEditingController _controller = TextEditingController();

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.goalSplit,
                          arguments: GoalSplitRouteArgs(
                            initialTitle: title.isEmpty ? null : title,
                          ),
                        );
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        AppRoutes.todoDetail,
                        arguments: const TodoDetailRouteArgs(isCreate: true),
                      );
                    },
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('手动创建待办'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _hasText
                        ? () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed(AppRoutes.todos);
                          }
                        : null,
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
