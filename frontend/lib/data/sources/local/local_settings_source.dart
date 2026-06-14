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
    await writeSemesterSettings(settings);
    return settings;
  }

  Future<SemesterTimetable> addSemesterTimetable({
    DateTime? startDate,
    int weekCount = 16,
    String owner = '我',
    String? schoolYear,
    SemesterTermType? termType,
  }) async {
    final settings = await getSemesterSettings();
    final now = clock.now();
    final date = startDate ?? DateTime(2026, 3, 2);
    final semesterSchoolYear = schoolYear ?? _schoolYear(date);
    final semesterTermType = termType ?? _termType(date);
    final semester = SemesterTimetable(
      id: 'semester-${now.microsecondsSinceEpoch}',
      name: generatedSemesterName(owner, semesterSchoolYear, semesterTermType),
      owner: owner,
      schoolYear: semesterSchoolYear,
      termType: semesterTermType,
      semesterStartDate: DateTime(date.year, date.month, date.day),
      weekCount: weekCount,
      createdAt: now,
      updatedAt: now,
    );
    _validateSemester(semester, settings.semesters);
    await writeSemesterSettings(
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
    final updatedSemester = semester.copyWith(updatedAt: clock.now());
    _validateSemester(updatedSemester, settings.semesters);
    final updated = [...settings.semesters];
    updated[index] = updatedSemester;
    await writeSemesterSettings(settings.copyWith(semesters: updated));
  }

  Future<SemesterTimetable> saveSemesterTimetable(
    SemesterTimetable semester,
  ) async {
    final settings = await getSemesterSettings();
    final exists = settings.semesterById(semester.id) != null;
    if (exists) {
      await updateSemesterTimetable(semester);
      return semester;
    }
    final savedSemester = semester.copyWith(updatedAt: clock.now());
    _validateSemester(savedSemester, settings.semesters);
    await writeSemesterSettings(
      settings.copyWith(
        semesters: [...settings.semesters, savedSemester],
        lastSelectedSemesterId: savedSemester.id,
      ),
    );
    return savedSemester;
  }

  Future<void> deleteSemesterTimetable(String semesterId) async {
    final settings = await getSemesterSettings();
    final updated = settings.semesters
        .where((semester) => semester.id != semesterId)
        .toList();
    final nextSelected = settings.lastSelectedSemesterId == semesterId
        ? (updated.isEmpty ? null : updated.last.id)
        : settings.lastSelectedSemesterId;
    await writeSemesterSettings(
      SemesterSettings(
        semesters: updated,
        periods: settings.periods,
        lastSelectedSemesterId: nextSelected,
      ),
    );
  }

  Future<void> setLastSelectedSemesterId(String semesterId) async {
    final settings = await getSemesterSettings();
    if (settings.semesterById(semesterId) == null) {
      return;
    }
    await writeSemesterSettings(
      settings.copyWith(lastSelectedSemesterId: semesterId),
    );
  }

  Future<void> writeSemesterSettings(SemesterSettings settings) async {
    _settings = settings;
    await store?.writeMap(LocalStoreKeys.settings, settings.toJson());
  }
}

void _validateSemester(
  SemesterTimetable semester,
  List<SemesterTimetable> existing,
) {
  if (semester.weekCount < 1 || semester.weekCount > 30) {
    throw ArgumentError.value(
      semester.weekCount,
      'weekCount',
      '学期持续周数需在 1-30 周之间',
    );
  }
  for (final other in existing) {
    if (other.id == semester.id) {
      continue;
    }
    if (_dateRangesOverlap(
      semester.semesterStartDate,
      semester.semesterEndDate,
      other.semesterStartDate,
      other.semesterEndDate,
    )) {
      throw StateError('学期日期范围不能重叠');
    }
  }
}

bool _dateRangesOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) {
  return !aEnd.isBefore(bStart) && !bEnd.isBefore(aStart);
}

String _schoolYear(DateTime date) {
  if (date.month >= 8) {
    return '${date.year}-${date.year + 1}';
  }
  return '${date.year - 1}-${date.year}';
}

SemesterTermType _termType(DateTime date) {
  return date.month <= 7 ? SemesterTermType.spring : SemesterTermType.autumn;
}
