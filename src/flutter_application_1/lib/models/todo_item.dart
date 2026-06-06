enum TodoStatus { open, done }

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.note,
    required this.dueAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String note;
  final DateTime? dueAt;
  final TodoStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasDeadline => dueAt != null;
}
