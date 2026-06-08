import 'package:equatable/equatable.dart';

/// A human-readable address resolved from a [GeoPosition] via reverse
/// geocoding. Pure-Dart entity — domain only.
class GeoAddress extends Equatable {
  const GeoAddress({
    this.street,
    this.locality,
    this.administrativeArea,
    this.country,
  });

  /// Sentinel used when geocoding has not produced a result yet, or returned
  /// nothing. Presentation translates this into a localized fallback string.
  static const GeoAddress unknown = GeoAddress();

  final String? street;
  final String? locality;
  final String? administrativeArea;
  final String? country;

  bool get isEmpty =>
      (street == null || street!.isEmpty) &&
      (locality == null || locality!.isEmpty) &&
      (administrativeArea == null || administrativeArea!.isEmpty) &&
      (country == null || country!.isEmpty);

  /// A single-line summary. Skips empty parts and joins with `, `.
  String get formatted {
    final parts = <String>[
      if (street != null && street!.isNotEmpty) street!,
      if (locality != null && locality!.isNotEmpty) locality!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, locality, administrativeArea, country];
}
