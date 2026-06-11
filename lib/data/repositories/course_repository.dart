import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCoursesForWeek(int week);
  Future<Course?> getNextCourse();
}
