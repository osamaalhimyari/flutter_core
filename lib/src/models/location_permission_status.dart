/// Domain-level mirror of the platform's location-permission state.
///
/// Lets the domain layer reason about permission without leaking the
/// `geolocator` package's `LocationPermission` type into use cases.
enum LocationPermissionStatus {
  /// Permission has not been requested yet.
  notDetermined,

  /// User has denied permission once but can still be re-asked.
  denied,

  /// User has permanently denied permission. Re-asking will fail — the user
  /// must change it in OS settings.
  deniedForever,

  /// Granted only while the app is in the foreground.
  whileInUse,

  /// Granted in foreground and background.
  always,

  /// Location services are turned off on the device entirely.
  servicesDisabled,
}

extension LocationPermissionStatusX on LocationPermissionStatus {
  /// `true` if a position request will succeed.
  bool get isGranted =>
      this == LocationPermissionStatus.whileInUse ||
      this == LocationPermissionStatus.always;
}
