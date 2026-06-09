import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/todo.dart';

class NextActionScreen extends StatefulWidget {
  const NextActionScreen({super.key});

  @override
  State<NextActionScreen> createState() => _NextActionScreenState();
}

class _NextActionScreenState extends State<NextActionScreen> {
  int _mood = 52;
  int _willingness = 68;
  int _anxiety = 35;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const PageTitleBar(title: '下一件事'),
            const SizedBox(height: 70),
            const CircleIcon(icon: Icons.psychology_alt_outlined, size: 76),
            const SizedBox(height: 18),
            Text('你现在感觉怎么样？', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 48),
            _MoodSlider(
              label: '心情',
              value: _mood,
              onChanged: (value) => setState(() => _mood = value),
            ),
            _MoodSlider(
              label: '启动意愿',
              value: _willingness,
              onChanged: (value) => setState(() => _willingness = value),
            ),
            _MoodSlider(
              label: '焦虑',
              value: _anxiety,
              onChanged: (value) => setState(() => _anxiety = value),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('recommend-todo-button'),
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.nextRecommendations,
                arguments: RecommendationInput(
                  mood: _mood,
                  willingness: _willingness,
                  anxiety: _anxiety,
                ),
              ),
              child: const Text('推荐待办'),
            ),
          ],
        ),
      ),
    );
  }
}

class NextRecommendationsScreen extends ConsumerStatefulWidget {
  const NextRecommendationsScreen({super.key});

  @override
  ConsumerState<NextRecommendationsScreen> createState() =>
      _NextRecommendationsScreenState();
}

class _NextRecommendationsScreenState
    extends ConsumerState<NextRecommendationsScreen> {
  late Future<List<TodoRecommendation>> _future;
  final Set<String> _addedTitles = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final input =
        ModalRoute.of(context)?.settings.arguments as RecommendationInput? ??
        const RecommendationInput(mood: 52, willingness: 68, anxiety: 35);
    _future = ref.read(todosControllerProvider.notifier).recommend(input);
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            PageTitleBar(
              title: '推荐待办',
              trailing: IconButton(
                tooltip: '换一批',
                onPressed: () => setState(() {
                  _future = ref
                      .read(todosControllerProvider.notifier)
                      .recommend(
                        const RecommendationInput(
                          mood: 45,
                          willingness: 50,
                          anxiety: 40,
                        ),
                      );
                }),
                icon: const Icon(Icons.refresh),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: FutureBuilder<List<TodoRecommendation>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final recommendations = snapshot.data!;
                  return ListView.separated(
                    itemCount: recommendations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = recommendations[index];
                      final added = _addedTitles.contains(item.title);
                      return _RecommendationCard(
                        item: item.copyWith(added: added),
                        onTap: item.todoId == null
                            ? null
                            : () => Navigator.of(context).pushNamed(
                                AppRoutes.todoDetail,
                                arguments: item.todoId,
                              ),
                        onAdd: item.canAdd
                            ? () async {
                                if (added) {
                                  setState(
                                    () => _addedTitles.remove(item.title),
                                  );
                                  return;
                                }
                                await ref
                                    .read(todosControllerProvider.notifier)
                                    .create(
                                      TodoDraft(
                                        title: item.title,
                                        content: item.reason,
                                        kind: TodoKind.normal,
                                        priority: 2,
                                        tags: const ['生活'],
                                      ),
                                    );
                                setState(() => _addedTitles.add(item.title));
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSlider extends StatelessWidget {
  const _MoodSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$value'),
            ],
          ),
          Slider(
            min: 1,
            max: 100,
            divisions: 99,
            value: value.toDouble(),
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  final TodoRecommendation item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.section,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  item.reason,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: item.added ? '取消添加' : '添加待办',
              onPressed: onAdd,
              icon: Icon(item.added ? Icons.close : Icons.add),
            ),
          ],
        ],
      ),
    );
  }
}
