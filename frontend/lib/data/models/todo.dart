enum TodoKind { duration, deadline, normal }

enum TodoStatus { open, done }

enum RepeatRule { once, daily, weekly, biweekly }

class PatchField<T> {
  const PatchField.omit() : isSet = false, value = null;
  const PatchField.value(this.value) : isSet = true;

  final bool isSet;
  final T? value;
}

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

  DateTime? get sortAt => deadlineAt ?? startAt;

  bool isDurationLockedAt(DateTime now) {
    return kind == TodoKind.duration &&
        status == TodoStatus.open &&
        (endAt == null || endAt!.isAfter(now));
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? content,
    String? location,
    TodoKind? kind,
    PatchField<DateTime> startAt = const PatchField.omit(),
    PatchField<DateTime> endAt = const PatchField.omit(),
    PatchField<DateTime> deadlineAt = const PatchField.omit(),
    double? priority,
    List<String>? tags,
    RepeatRule? repeatRule,
    TodoStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      kind: kind ?? this.kind,
      startAt: startAt.isSet ? startAt.value : this.startAt,
      endAt: endAt.isSet ? endAt.value : this.endAt,
      deadlineAt: deadlineAt.isSet ? deadlineAt.value : this.deadlineAt,
      priority: priority ?? this.priority,
      tags: List.unmodifiable(tags ?? this.tags),
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  TodoItem withAutoCompletion(DateTime now) {
    if (kind != TodoKind.duration ||
        status == TodoStatus.done ||
        endAt == null ||
        endAt!.isAfter(now)) {
      return this;
    }
    return copyWith(status: TodoStatus.done, updatedAt: now);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'location': location,
      'kind': kind.name,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'deadlineAt': deadlineAt?.toIso8601String(),
      'priority': priority,
      'tags': tags,
      'repeatRule': repeatRule.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, Object?> json) {
    return TodoItem(
      id: json['id']! as String,
      title: json['title']! as String,
      content: json['content']! as String,
      location: json['location']! as String,
      kind: TodoKind.values.byName(json['kind']! as String),
      startAt: _parseDate(json['startAt']),
      endAt: _parseDate(json['endAt']),
      deadlineAt: _parseDate(json['deadlineAt']),
      priority: (json['priority']! as num).toDouble(),
      tags: List<String>.from(json['tags']! as List),
      repeatRule: RepeatRule.values.byName(json['repeatRule']! as String),
      status: TodoStatus.values.byName(json['status']! as String),
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
    );
  }
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
    this.title = const PatchField.omit(),
    this.content = const PatchField.omit(),
    this.location = const PatchField.omit(),
    this.kind = const PatchField.omit(),
    this.startAt = const PatchField.omit(),
    this.endAt = const PatchField.omit(),
    this.deadlineAt = const PatchField.omit(),
    this.priority = const PatchField.omit(),
    this.tags = const PatchField.omit(),
    this.repeatRule = const PatchField.omit(),
    this.status = const PatchField.omit(),
  });

  final PatchField<String> title;
  final PatchField<String> content;
  final PatchField<String> location;
  final PatchField<TodoKind> kind;
  final PatchField<DateTime> startAt;
  final PatchField<DateTime> endAt;
  final PatchField<DateTime> deadlineAt;
  final PatchField<double> priority;
  final PatchField<List<String>> tags;
  final PatchField<RepeatRule> repeatRule;
  final PatchField<TodoStatus> status;
}

class TodoFilter {
  const TodoFilter({
    this.date,
    this.kinds = const [TodoKind.duration, TodoKind.deadline, TodoKind.normal],
    this.statuses = const [TodoStatus.open, TodoStatus.done],
    this.tags = const [],
    this.onlyDeadline = false,
  });

  final DateTime? date;
  final List<TodoKind> kinds;
  final List<TodoStatus> statuses;
  final List<String> tags;
  final bool onlyDeadline;

  bool matches(TodoItem item) {
    if (onlyDeadline && item.kind != TodoKind.deadline) {
      return false;
    }
    if (!kinds.contains(item.kind)) {
      return false;
    }
    if (!statuses.contains(item.status)) {
      return false;
    }
    if (tags.isNotEmpty && !item.tags.any(tags.contains)) {
      return false;
    }
    if (date != null) {
      final itemDate = item.sortAt;
      if (itemDate == null || !_sameDay(itemDate, date!)) {
        return false;
      }
    }
    return true;
  }

  TodoFilter copyWith({
    PatchField<DateTime> date = const PatchField.omit(),
    List<TodoKind>? kinds,
    List<TodoStatus>? statuses,
    List<String>? tags,
    bool? onlyDeadline,
  }) {
    return TodoFilter(
      date: date.isSet ? date.value : this.date,
      kinds: kinds ?? this.kinds,
      statuses: statuses ?? this.statuses,
      tags: tags ?? this.tags,
      onlyDeadline: onlyDeadline ?? this.onlyDeadline,
    );
  }
}

DateTime? _parseDate(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
