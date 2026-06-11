import '../models/recommendation.dart';

abstract class RecommendationRepository {
  Future<List<TodoRecommendation>> getRecommendations(
    RecommendationInput input,
  );
}
