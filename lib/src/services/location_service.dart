import '../models/geo_position.dart';
import '../models/location_permission_status.dart';

/// Platform-agnostic abstraction over device GPS. **Your app** implements this
/// (e.g. a `GeolocatorLocationService` in `lib/logic/`) and registers it with
/// your DI — core ships the contract + entities, not the geolocator binding.
abstract class LocationService {
  /// Returns `true` when location services (the OS-level toggle) are enabled.
  Future<bool> isServiceEnabled();

  /// Reads the app's current permission state without prompting.
  Future<LocationPermissionStatus> checkPermission();

  /// Requests permission from the user. Returns the resulting state.
  /// Idempotent — calling when already granted returns immediately.
  Future<LocationPermissionStatus> requestPermission();

  /// Reads a single GPS fix. Throws [LocationServiceException] if the service
  /// is disabled or permission is missing — the caller maps that to a Failure.
  Future<GeoPosition> getCurrentPosition();

  /// A continuous stream of position updates. [minimumDistanceMeters] tells
  /// the OS to skip emissions smaller than that — useful for power on Android.
  Stream<GeoPosition> watchPosition({double minimumDistanceMeters = 5});

  /// Open the OS-level location-services screen. Returns `true` if opened.
  Future<bool> openLocationSettings();

  /// Open this app's settings screen (for a permanently-denied permission).
  /// Returns `true` if opened.
  Future<bool> openAppSettings();
}

/// Thrown by [LocationService] implementations when the device cannot produce a
/// fix (services off, permission denied, timeout).
class LocationServiceException implements Exception {
  const LocationServiceException(this.code, [this.message]);

  final LocationServiceErrorCode code;
  final String? message;

  @override
  String toString() => 'LocationServiceException($code, $message)';
}

enum LocationServiceErrorCode {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}
