import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCoursesForWeek(int week, {String? semesterId});
  Future<Course?> getCourseById(String courseId);
  Future<Course?> getNextCourse();
  Future<Course> createCourse(CourseDraft draft);
  Future<Course> updateCourse(String courseId, CourseDraft draft);
  Future<Course> cancelCourseForWeek(String courseId, int week);
  Future<void> deleteCourse(String courseId);
  String colorKeyForCourseName(String name);
}
