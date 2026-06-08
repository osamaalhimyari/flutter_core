import 'package:my_core/my_core.dart';
import 'package:geocoding/geocoding.dart' as geo;

/// [GeocodingService] backed by `package:geocoding`.
class GeocoderGeocodingService implements GeocodingService {
  @override
  Future<GeoAddress> reverseGeocode({
    required double latitude,
    required double longitude,
    String? localeCode,
  }) async {
    if (localeCode != null) {
      await geo.setLocaleIdentifier(localeCode);
    }
    final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return GeoAddress.unknown;
    final p = placemarks.first;
    return GeoAddress(
      street: p.street,
      locality: p.locality,
      administrativeArea: p.administrativeArea,
      country: p.country,
    );
  }
}
