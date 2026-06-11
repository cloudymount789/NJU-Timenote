enum TodoKind { duration, deadline, normal }

enum TodoStatus { open, done }

enum RepeatRule { once, daily, weekly }

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.kind,
    required this.startAt,
    required this.endAt,
    required this.deadlineAt,
    required this.priority,
    required this.tags,
    required this.repeatRule,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String location;
  final TodoKind kind;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final double priority;
  final List<String> tags;
  final RepeatRule repeatRule;
  final TodoStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TodoDraft {
  const TodoDraft({
    required this.title,
    this.content = '',
    this.location = '',
    this.kind = TodoKind.normal,
    this.startAt,
    this.endAt,
    this.deadlineAt,
    this.priority = 0,
    this.tags = const [],
    this.repeatRule = RepeatRule.once,
  });

  final String title;
  final String content;
  final String location;
  final TodoKind kind;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final double priority;
  final List<String> tags;
  final RepeatRule repeatRule;
}

class TodoPatch {
  const TodoPatch({
    this.title,
    this.content,
    this.location,
    this.kind,
    this.startAt,
    this.endAt,
    this.deadlineAt,
    this.priority,
    this.tags,
    this.repeatRule,
    this.status,
  });

  final String? title;
  final String? content;
  final String? location;
  final TodoKind? kind;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final double? priority;
  final List<String>? tags;
  final RepeatRule? repeatRule;
  final TodoStatus? status;
}

class TodoFilter {
  const TodoFilter({
    this.date,
    this.kinds = const [],
    this.statuses = const [],
    this.tags = const [],
    this.onlyDeadline = false,
  });

  final DateTime? date;
  final List<TodoKind> kinds;
  final List<TodoStatus> statuses;
  final List<String> tags;
  final bool onlyDeadline;
}
