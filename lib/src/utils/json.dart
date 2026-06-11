/// Defensive JSON coercion helpers. Parsing must never throw inside a list or
/// detail builder — a malformed field should degrade to a sane default, not
/// crash the screen. Use in `*Model.fromJson` factories.
abstract class Json {
  static int asInt(Object? v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int? asIntOrNull(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double asDouble(Object? v, [double fallback = 0]) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static String asString(Object? v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static String? asStringOrNull(Object? v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static bool asBool(Object? v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == 'true' || v == '1';
    return fallback;
  }

  /// Safely read a nested object as a `Map<String, dynamic>`, or null.
  static Map<String, dynamic>? asMap(Object? v) =>
      v is Map<String, dynamic> ? v : null;
}
