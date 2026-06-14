import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';

class TodoTagRouteArgs {
  const TodoTagRouteArgs({this.initialTags = const []});

  final List<String> initialTags;
}

class TodoTagPage extends StatefulWidget {
  const TodoTagPage({required this.initialTags, super.key});

  final List<String> initialTags;

  @override
  State<TodoTagPage> createState() => _TodoTagPageState();
}

class _TodoTagPageState extends State<TodoTagPage> {
  late final Set<String> _selected = {...widget.initialTags};
  Future<List<String>>? _future;
  var _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _future = _load();
  }

  Future<List<String>> _load() {
    return AppScope.repositoriesOf(context).tags.getTags();
  }

  Future<void> _addTag() async {
    final controller = TextEditingController();
    final repo = AppScope.repositoriesOf(context).tags;
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => _AddTagDialog(controller: controller),
    );
    controller.dispose();
    if (tag == null || !mounted) {
      return;
    }
    final saved = await repo.addTag(tag);
    if (!mounted) {
      return;
    }
    setState(() {
      _selected.add(saved);
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
        child: Column(
          children: [
            AppHeader(
              title: '选择 Tag',
              onBack: () =>
                  Navigator.of(context).pop(_selected.toList()..sort()),
              trailing: AppIconButton(
                icon: Icons.add,
                tooltip: '新增 tag',
                onPressed: _addTag,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: DecoratedBox(
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
                child: FutureBuilder<List<String>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingState();
                    }
                    if (snapshot.hasError) {
                      return ErrorState(message: '${snapshot.error}');
                    }
                    final tags = snapshot.data ?? const [];
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: tags
                            .map(
                              (tag) => FilterChip(
                                label: Text(tag),
                                selected: _selected.contains(tag),
                                onSelected: (_) => setState(() {
                                  _selected.contains(tag)
                                      ? _selected.remove(tag)
                                      : _selected.add(tag);
                                }),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_selected.toList()..sort()),
                child: const Text('完成'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog({required this.controller});

  final TextEditingController controller;

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 45),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '新增 Tag',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: widget.controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: '请输入 tag 名称'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: widget.controller.text.trim().isEmpty
                        ? null
                        : () =>
                              Navigator.of(context).pop(widget.controller.text),
                    child: const Text('确定'),
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
