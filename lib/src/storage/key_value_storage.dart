import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Typed key-value persistence for app preferences/flags, the selected
/// locale/theme, and arbitrary JSON objects.
abstract class KeyValueStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);

  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);

  /// Read a JSON object previously stored with [writeJson]. Returns `null` if
  /// absent or not a JSON object.
  Future<Map<String, dynamic>?> readJson(String key);

  /// Store a JSON object (serialized). Round-trips with [readJson].
  Future<void> writeJson(String key, Map<String, dynamic> value);

  Future<void> remove(String key);
  Future<void> clear();
}

/// [KeyValueStorage] backed by `shared_preferences`. The default used by
/// `Core.init` when you don't pass your own — this is what persists the
/// selected locale/theme across launches.
class SharedPrefsStorage implements KeyValueStorage {
  final SharedPreferences _prefs;
  SharedPrefsStorage(this._prefs);

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);
  @override
  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<bool?> readBool(String key) async => _prefs.getBool(key);
  @override
  Future<void> writeBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  @override
  Future<void> remove(String key) => _prefs.remove(key);
  @override
  Future<void> clear() => _prefs.clear();
}

/// Non-persistent [KeyValueStorage] kept in memory. Handy in tests.
class InMemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, Object?> _m = {};

  @override
  Future<String?> readString(String key) async => _m[key] as String?;
  @override
  Future<void> writeString(String key, String value) async => _m[key] = value;

  @override
  Future<bool?> readBool(String key) async => _m[key] as bool?;
  @override
  Future<void> writeBool(String key, bool value) async => _m[key] = value;

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final v = _m[key];
    return v is Map<String, dynamic> ? v : null;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async =>
      _m[key] = value;

  @override
  Future<void> remove(String key) async => _m.remove(key);
  @override
  Future<void> clear() async => _m.clear();
}
