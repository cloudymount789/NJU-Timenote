import '../../../core/time/app_clock.dart';
import '../../models/settings.dart';
import 'local_json_store.dart';

class LocalSettingsSource {
  LocalSettingsSource({this.clock = const AppClock(), this.store});

  final AppClock clock;
  final LocalJsonStore? store;
  SemesterSettings? _settings;

  Future<SemesterSettings> getSemesterSettings() async {
    final cached = _settings;
    if (cached != null) {
      return cached;
    }
    final data = store?.readMap(LocalStoreKeys.settings);
    if (data != null && data.isNotEmpty) {
      final settings = SemesterSettings.fromJson(data);
      if (settings.semesters.isNotEmpty) {
        _settings = settings;
        return settings;
      }
    }
    final settings = SemesterSettings(
      semesters: [defaultSemesterTimetable],
      periods: const [],
      lastSelectedSemesterId: defaultSemesterTimetable.id,
    );
    await saveSemesterSettings(settings);
    return settings;
  }

  Future<SemesterTimetable> addSemesterTimetable({
    DateTime? startDate,
    int weekCount = 16,
  }) async {
    final settings = await getSemesterSettings();
    final now = clock.now();
    final date = startDate ?? DateTime(2026, 3, 2);
    final semester = SemesterTimetable(
      id: 'semester-${now.microsecondsSinceEpoch}',
      name: _semesterName(date),
      semesterStartDate: DateTime(date.year, date.month, date.day),
      weekCount: weekCount,
      createdAt: now,
    );
    await saveSemesterSettings(
      settings.copyWith(
        semesters: [...settings.semesters, semester],
        lastSelectedSemesterId: semester.id,
      ),
    );
    return semester;
  }

  Future<void> updateSemesterTimetable(SemesterTimetable semester) async {
    final settings = await getSemesterSettings();
    final index = settings.semesters.indexWhere(
      (item) => item.id == semester.id,
    );
    if (index == -1) {
      throw StateError('学期课表不存在');
    }
    final updated = [...settings.semesters];
    updated[index] = semester;
    await saveSemesterSettings(settings.copyWith(semesters: updated));
  }

  Future<void> setLastSelectedSemesterId(String semesterId) async {
    final settings = await getSemesterSettings();
    if (settings.semesterById(semesterId) == null) {
      return;
    }
    await saveSemesterSettings(
      settings.copyWith(lastSelectedSemesterId: semesterId),
    );
  }

  Future<void> saveSemesterSettings(SemesterSettings settings) async {
    _settings = settings;
    await store?.writeMap(LocalStoreKeys.settings, settings.toJson());
  }
}

String _semesterName(DateTime date) {
  final season = date.month <= 7 ? '春季学期' : '秋季学期';
  return '${date.year} $season';
}
