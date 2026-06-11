class LocalTagSource {
  LocalTagSource({
    Iterable<String> initialTags = const ['考试', '作业', '讲座', '会议', '生活', '学习'],
  }) : _tags = {...initialTags};

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
    return normalized;
  }

  Future<void> addTags(Iterable<String> tags) async {
    for (final tag in tags) {
      final normalized = tag.trim();
      if (normalized.isNotEmpty) {
        _tags.add(normalized);
      }
    }
  }
}
