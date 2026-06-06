import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> fetchCourses({required int week});
  Future<Course> addCourse(CourseDraft draft);
  Future<void> deleteCourse(String courseId);
  Future<List<Course>> importCoursesFromScreenshot();
}

class MockCourseRepository implements CourseRepository {
  MockCourseRepository() : _courses = _seedCourses();

  final List<Course> _courses;
  int _nextId = 100;

  @override
  Future<List<Course>> fetchCourses({required int week}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _courses.where((course) => course.occursInWeek(week)).toList();
  }

  @override
  Future<Course> addCourse(CourseDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final now = DateTime.now();
    final course = Course(
      id: 'course-${_nextId++}',
      name: draft.name,
      teacher: draft.teacher,
      location: draft.location,
      note: draft.note,
      dayOfWeek: draft.dayOfWeek,
      startPeriod: draft.startPeriod,
      endPeriod: draft.endPeriod,
      weekRule: draft.weekRule,
      startWeek: draft.startWeek,
      endWeek: draft.endWeek,
      colorKey: _colorForName(draft.name),
      source: draft.source,
      createdAt: now,
      updatedAt: now,
    );
    _courses.add(course);
    return course;
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _courses.removeWhere((course) => course.id == courseId);
  }

  @override
  Future<List<Course>> importCoursesFromScreenshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final imported = [
      const CourseDraft(
        name: '软件工程',
        teacher: '陈老师',
        location: '仙林 B406',
        note: '由课表截图识别',
        dayOfWeek: 5,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        source: CourseSource.screenshot,
      ),
      const CourseDraft(
        name: '人工智能导论',
        teacher: '李老师',
        location: '鼓楼 逸夫楼',
        note: '由课表截图识别',
        dayOfWeek: 2,
        startPeriod: 9,
        endPeriod: 10,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        source: CourseSource.screenshot,
      ),
    ];

    final courses = <Course>[];
    for (final draft in imported) {
      courses.add(await addCourse(draft));
    }
    return courses;
  }

  static String _colorForName(String name) {
    const keys = ['blue', 'purple', 'pink', 'indigo'];
    final index =
        name.runes.fold<int>(0, (sum, rune) => sum + rune) % keys.length;
    return keys[index];
  }

  static List<Course> _seedCourses() {
    final now = DateTime(2026, 4, 1);
    Course course(
      String id,
      String name,
      String location,
      int day,
      int start,
      int end,
      String color, {
      String teacher = '',
    }) {
      return Course(
        id: id,
        name: name,
        teacher: teacher,
        location: location,
        note: '',
        dayOfWeek: day,
        startPeriod: start,
        endPeriod: end,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        colorKey: color,
        source: CourseSource.sample,
        createdAt: now,
        updatedAt: now,
      );
    }

    return [
      course('c1', '微积分 II', '馆1-105', 1, 1, 2, 'purple'),
      course('c2', '离散数学', '馆2-302', 1, 3, 4, 'purple'),
      course('c3', '编译原理', '馆1-210', 1, 7, 8, 'purple'),
      course('c4', '数字逻辑', 'B503', 2, 3, 4, 'blue'),
      course('c5', '数据结构', '机房A', 3, 5, 6, 'pink'),
      course('c6', '高级编程', '教学楼③', 3, 3, 4, 'pink'),
      course('c7', '数据库', '教学楼②', 3, 7, 8, 'pink'),
      course('c8', '思修', '大教202', 4, 10, 11, 'pink'),
      course('c9', '线性代数', '逸C-101', 4, 3, 4, 'blue'),
      course('c10', '操作系统', '计科楼', 4, 5, 6, 'purple'),
      course('c11', '大学英语', '外院201', 5, 1, 2, 'pink'),
      course('c12', '计算机网络', 'B202', 5, 5, 7, 'blue'),
    ];
  }
}
