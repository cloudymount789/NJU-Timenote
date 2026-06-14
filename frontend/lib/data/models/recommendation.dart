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
  });

  final String section;
  final String title;
  final String reason;
  final String? todoId;
  final bool canAdd;
}
