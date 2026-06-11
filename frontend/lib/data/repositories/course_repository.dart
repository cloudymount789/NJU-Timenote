import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCoursesForWeek(int week);
  Future<Course?> getNextCourse();
  Future<Course> createCourse(CourseDraft draft);
  Future<void> deleteCourse(String courseId);
  String colorKeyForCourseName(String name);
}
