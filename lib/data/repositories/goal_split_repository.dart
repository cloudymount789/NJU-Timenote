import '../models/goal_split.dart';

abstract class GoalSplitRepository {
  Future<void> createFromGoalSplit(GoalSplitDraft draft);
}
