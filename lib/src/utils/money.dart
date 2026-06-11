import 'package:intl/intl.dart';

/// Currency + number formatting so amounts render identically across an app.
/// Western digits regardless of locale; only the surrounding text localizes.
/// The currency symbol defaults to `SAR` but is per-call overridable.
abstract class Money {
  static final NumberFormat _amount = NumberFormat('#,##0.00', 'en');
  static final NumberFormat _liters = NumberFormat('#,##0.##', 'en');

  /// e.g. `123.45` → `123.45 SAR`.
  static String amount(num value, {String symbol = 'SAR'}) =>
      '${_amount.format(value)} $symbol';

  /// Bare amount with no currency symbol (right-aligned columns).
  static String bare(num value) => _amount.format(value);

  /// e.g. `12.5` → `12.5 L`.
  static String liters(num value, {String unit = 'L'}) =>
      '${_liters.format(value)} $unit';

  /// A unit price with no symbol (caller appends `/L`).
  static String unit(num value) => _amount.format(value);
}
