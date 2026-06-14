enum TodoStatus { open, done }

enum TodoKind { duration, deadline, normal }

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

  bool get hasDeadline => deadlineAt != null || kind == TodoKind.deadline;
  bool get hasDuration => startAt != null && endAt != null;
  bool get isDone => status == TodoStatus.done;

  TodoItem copyWith({
    String? id,
    String? title,
    String? content,
    String? location,
    TodoKind? kind,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? deadlineAt,
    double? priority,
    List<String>? tags,
    RepeatRule? repeatRule,
    TodoStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDuration = false,
    bool clearDeadline = false,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      kind: kind ?? this.kind,
      startAt: clearDuration ? null : startAt ?? this.startAt,
      endAt: clearDuration ? null : endAt ?? this.endAt,
      deadlineAt: clearDeadline ? null : deadlineAt ?? this.deadlineAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    this.priority = 3,
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
    this.clearDuration = false,
    this.clearDeadline = false,
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
  final bool clearDuration;
  final bool clearDeadline;
}

class TodoFilter {
  const TodoFilter({
    this.date,
    this.kinds = const {},
    this.statuses = const {},
    this.tags = const {},
    this.onlyDeadline = false,
  });

  final DateTime? date;
  final Set<TodoKind> kinds;
  final Set<TodoStatus> statuses;
  final Set<String> tags;
  final bool onlyDeadline;

  bool get isActive =>
      date != null ||
      kinds.isNotEmpty ||
      statuses.isNotEmpty ||
      tags.isNotEmpty ||
      onlyDeadline;

  TodoFilter copyWith({
    DateTime? date,
    Set<TodoKind>? kinds,
    Set<TodoStatus>? statuses,
    Set<String>? tags,
    bool? onlyDeadline,
    bool clearDate = false,
  }) {
    return TodoFilter(
      date: clearDate ? null : date ?? this.date,
      kinds: kinds ?? this.kinds,
      statuses: statuses ?? this.statuses,
      tags: tags ?? this.tags,
      onlyDeadline: onlyDeadline ?? this.onlyDeadline,
    );
  }
}

class RecommendationInput {
  const RecommendationInput({
    required this.mood,
    required this.willingness,
    required this.anxiety,
  });

  final int mood;
  final int willingness;
  final int anxiety;
}

class TodoRecommendation {
  const TodoRecommendation({
    required this.section,
    required this.title,
    required this.reason,
    this.todoId,
    this.canAdd = false,
    this.added = false,
  });

  final String section;
  final String title;
  final String reason;
  final String? todoId;
  final bool canAdd;
  final bool added;

  TodoRecommendation copyWith({bool? added}) {
    return TodoRecommendation(
      section: section,
      title: title,
      reason: reason,
      todoId: todoId,
      canAdd: canAdd,
      added: added ?? this.added,
    );
  }
}

class GoalSplitDraft {
  const GoalSplitDraft({
    required this.title,
    required this.finalDeadline,
    this.note = '',
    this.subtasks = const [],
  });

  final String title;
  final String note;
  final DateTime finalDeadline;
  final List<GoalSubtaskDraft> subtasks;

  GoalSplitDraft copyWith({
    String? title,
    String? note,
    DateTime? finalDeadline,
    List<GoalSubtaskDraft>? subtasks,
  }) {
    return GoalSplitDraft(
      title: title ?? this.title,
      note: note ?? this.note,
      finalDeadline: finalDeadline ?? this.finalDeadline,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

class GoalSubtaskDraft {
  const GoalSubtaskDraft({required this.title, required this.plannedDate});

  final String title;
  final DateTime plannedDate;
}
