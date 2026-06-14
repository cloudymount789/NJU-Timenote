abstract class TagRepository {
  Future<List<String>> getTags();
  Future<String> addTag(String name);
}
