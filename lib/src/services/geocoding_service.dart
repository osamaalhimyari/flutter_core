import '../models/geo_address.dart';

/// Platform-agnostic abstraction over reverse geocoding. **Your app**
/// implements this (typically wrapping `package:geocoding`). Returning
/// [GeoAddress.unknown] (instead of throwing) is preferred when the lookup
/// simply found nothing — geocoding is best-effort, not authoritative.
abstract class GeocodingService {
  /// Resolves a coordinate into a human-readable address. Returns
  /// [GeoAddress.unknown] if the geocoder returns no placemarks; may throw on
  /// transport errors (the caller converts that to a Failure).
  Future<GeoAddress> reverseGeocode({
    required double latitude,
    required double longitude,
    String? localeCode,
  });
}
