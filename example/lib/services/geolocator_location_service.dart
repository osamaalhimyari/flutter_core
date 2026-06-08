import 'package:my_core/my_core.dart';
import 'package:geolocator/geolocator.dart';

/// [LocationService] backed by `geolocator`. This is the kind of impl that
/// lives in your app's `lib/logic/` and gets registered with your DI.
class GeolocatorLocationService implements LocationService {
  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.servicesDisabled;
    }
    return _map(await Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      _map(await Geolocator.requestPermission());

  @override
  Future<GeoPosition> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        LocationServiceErrorCode.servicesDisabled,
      );
    }
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw LocationServiceException(
        perm == LocationPermission.deniedForever
            ? LocationServiceErrorCode.permissionDeniedForever
            : LocationServiceErrorCode.permissionDenied,
      );
    }
    return _toGeo(await Geolocator.getCurrentPosition());
  }

  @override
  Stream<GeoPosition> watchPosition({double minimumDistanceMeters = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: minimumDistanceMeters.round(),
      ),
    ).map(_toGeo);
  }

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  GeoPosition _toGeo(Position p) => GeoPosition(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracyMeters: p.accuracy,
    headingDegrees: p.heading,
    speedMetersPerSecond: p.speed,
    recordedAt: p.timestamp,
  );

  LocationPermissionStatus _map(LocationPermission p) => switch (p) {
    LocationPermission.denied => LocationPermissionStatus.denied,
    LocationPermission.deniedForever => LocationPermissionStatus.deniedForever,
    LocationPermission.whileInUse => LocationPermissionStatus.whileInUse,
    LocationPermission.always => LocationPermissionStatus.always,
    LocationPermission.unableToDetermine =>
      LocationPermissionStatus.notDetermined,
  };
}
