import 'package:intl/intl.dart';

/// Date/time formatting for API (ISO-8601) timestamps. Parse defensively — a
/// bad/empty value yields null rather than throwing in a list builder.
abstract class AppDate {
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  /// Parse an ISO-8601 string to local time, or null when absent/invalid.
  static DateTime? parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }

  /// `HH:mm`.
  static String time(DateTime? dt) => dt == null ? '—' : _time.format(dt);

  /// `yyyy-MM-dd HH:mm`.
  static String dateTime(DateTime? dt) =>
      dt == null ? '—' : _dateTime.format(dt);

  /// `yyyy-MM-dd` (e.g. an API `date` filter value).
  static String apiDate(DateTime dt) => _date.format(dt);
}
