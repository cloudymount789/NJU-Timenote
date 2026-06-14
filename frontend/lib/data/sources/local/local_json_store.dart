import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalJsonStore {
  const LocalJsonStore(this._preferences);

  final SharedPreferences _preferences;

  Map<String, Object?> readMap(String key) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
    return const {};
  }

  Future<void> writeMap(String key, Map<String, Object?> value) async {
    await _preferences.setString(key, jsonEncode(value));
  }
}

class LocalStoreKeys {
  const LocalStoreKeys._();

  static const courses = 'nju_timenote.courses.v1';
  static const todos = 'nju_timenote.todos.v1';
  static const tags = 'nju_timenote.tags.v1';
  static const settings = 'nju_timenote.settings.v1';
}
