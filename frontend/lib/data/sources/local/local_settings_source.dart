import '../../models/settings.dart';
import 'local_json_store.dart';

class LocalSettingsSource {
  LocalSettingsSource({this.store});

  final LocalJsonStore? store;

  Future<SemesterSettings> getSemesterSettings() async {
    final data = store?.readMap(LocalStoreKeys.settings);
    if (data != null && data.isNotEmpty) {
      return SemesterSettings.fromJson(data);
    }
    final settings = SemesterSettings(
      semesterStartDate: DateTime(2026, 9),
      periods: const [],
    );
    await store?.writeMap(LocalStoreKeys.settings, settings.toJson());
    return settings;
  }
}
