import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/recommendation.dart';
import '../../data/models/todo.dart';

class NextThingPage extends StatefulWidget {
  const NextThingPage({super.key});

  @override
  State<NextThingPage> createState() => _NextThingPageState();
}

class _NextThingPageState extends State<NextThingPage> {
  double _mood = 52;
  double _willingness = 68;
  double _anxiety = 35;

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.xl,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        child: Column(
          children: [
            AppHeader(
              title: '下一件事',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.psychology_alt_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '你现在感觉怎么样？',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 26),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220062FF),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                child: Column(
                  children: [
                    _StateSlider(
                      label: '心情',
                      value: _mood,
                      onChanged: (value) => setState(() => _mood = value),
                    ),
                    _StateSlider(
                      label: '启动意愿',
                      value: _willingness,
                      onChanged: (value) =>
                          setState(() => _willingness = value),
                    ),
                    _StateSlider(
                      label: '焦虑',
                      value: _anxiety,
                      onChanged: (value) => setState(() => _anxiety = value),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.nextThingRecommend,
                  arguments: RecommendationRouteArgs(
                    input: RecommendationInput(
                      mood: _mood.round(),
                      willingness: _willingness.round(),
                      anxiety: _anxiety.round(),
                    ),
                  ),
                ),
                child: const Text('推荐待办'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NextThingRecommendPage extends StatefulWidget {
  const NextThingRecommendPage({required this.input, super.key});

  final RecommendationInput input;

  @override
  State<NextThingRecommendPage> createState() => _NextThingRecommendPageState();
}

class _NextThingRecommendPageState extends State<NextThingRecommendPage> {
  Future<List<TodoRecommendation>>? _future;
  var _didLoad = false;
  String? _addedSuggestionTodoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _future = _load();
  }

  Future<List<TodoRecommendation>> _load() {
    return AppScope.repositoriesOf(
      context,
    ).recommendations.getRecommendations(widget.input);
  }

  Future<void> _addOrRemoveSuggestion(TodoRecommendation recommendation) async {
    final repo = AppScope.repositoriesOf(context).todos;
    if (_addedSuggestionTodoId != null) {
      await repo.deleteTodo(_addedSuggestionTodoId!);
      setState(() => _addedSuggestionTodoId = null);
      return;
    }
    final todo = await repo.createTodo(TodoDraft(title: recommendation.title));
    setState(() => _addedSuggestionTodoId = todo.id);
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            AppHeader(
              title: '推荐待办',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TodoRecommendation>>(
                future: _future ?? Future.value(const <TodoRecommendation>[]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingState();
                  }
                  if (snapshot.hasError) {
                    return ErrorState(message: '${snapshot.error}');
                  }
                  final items = snapshot.data ?? const [];
                  final userItems = items
                      .where((item) => item.todoId != null)
                      .toList();
                  final suggestionItems = items
                      .where((item) => item.canAdd)
                      .toList();
                  if (userItems.isEmpty && suggestionItems.isEmpty) {
                    return const Center(child: EmptyState(title: '暂无推荐'));
                  }
                  return ListView(
                    children: [
                      if (userItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: EmptyState(
                            title: '还没有可推荐的待办',
                            message: '添加待办后，这里会从你的列表中挑选。',
                          ),
                        )
                      else
                        ...userItems.map(_RecommendationCard.new),
                      ...suggestionItems.map(
                        (item) => _RecommendationCard(
                          item,
                          trailing: IconButton(
                            tooltip: _addedSuggestionTodoId == null
                                ? '添加'
                                : '取消添加',
                            onPressed: () => _addOrRemoveSuggestion(item),
                            icon: Icon(
                              _addedSuggestionTodoId == null
                                  ? Icons.add
                                  : Icons.close,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              tooltip: '换一批',
              onPressed: () => setState(() => _future = _load()),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateSlider extends StatelessWidget {
  const _StateSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Slider(
            min: 1,
            max: 100,
            divisions: 99,
            value: value,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 34, child: Text(value.round().toString())),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard(this.item, {this.trailing});

  final TodoRecommendation item;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${item.section}\n${item.reason}'),
        trailing: trailing,
        onTap: item.todoId == null
            ? null
            : () => Navigator.of(context).pushNamed(
                AppRoutes.todoDetail,
                arguments: TodoDetailRouteArgs(todoId: item.todoId),
              ),
      ),
    );
  }
}
