import '../../models/course.dart';

class LocalCourseSource {
  Future<List<Course>> getCoursesForWeek(int week) async {
    return const [];
  }

  Future<Course?> getNextCourse() async {
    return null;
  }
}
