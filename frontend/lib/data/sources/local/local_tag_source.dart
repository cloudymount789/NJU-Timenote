import 'local_json_store.dart';

class LocalTagSource {
  LocalTagSource({
    Iterable<String> initialTags = const ['考试', '作业', '讲座', '会议', '生活', '学习'],
    this.store,
  }) : _tags = {...initialTags} {
    _restore(initialTags);
  }

  final LocalJsonStore? store;
  final Set<String> _tags;

  Future<List<String>> getTags() async {
    final tags = _tags.toList()..sort();
    return tags;
  }

  Future<String> addTag(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(name, 'name', 'tag 不能为空');
    }
    _tags.add(normalized);
    await _persist();
    return normalized;
  }

  Future<void> addTags(Iterable<String> tags) async {
    var changed = false;
    for (final tag in tags) {
      final normalized = tag.trim();
      if (normalized.isNotEmpty) {
        changed = _tags.add(normalized) || changed;
      }
    }
    if (changed) {
      await _persist();
    }
  }

  void _restore(Iterable<String> initialTags) {
    final data = store?.readMap(LocalStoreKeys.tags);
    if (data == null || data.isEmpty) {
      return;
    }
    final storedTags = data['tags'] as List? ?? const [];
    _tags
      ..clear()
      ..addAll(initialTags)
      ..addAll(storedTags.cast<String>());
  }

  Future<void> _persist() async {
    final localStore = store;
    if (localStore == null) {
      return;
    }
    await localStore.writeMap(LocalStoreKeys.tags, {
      'tags': _tags.toList()..sort(),
    });
  }
}
