class GoalSplitDraft {
  const GoalSplitDraft({
    required this.title,
    required this.note,
    required this.finalDeadline,
    required this.subtasks,
  });

  final String title;
  final String note;
  final DateTime finalDeadline;
  final List<GoalSubtaskDraft> subtasks;
}

class GoalSubtaskDraft {
  const GoalSubtaskDraft({required this.title, required this.plannedDate});

  final String title;
  final DateTime plannedDate;
}
