import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A single fix from the device's GPS.
///
/// Pure-Dart entity — no Flutter packages, so it lives in the domain layer.
/// The presentation layer adapts it into `LatLng` for `google_maps_flutter`.
class GeoPosition extends Equatable {
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracyMeters,
    this.headingDegrees,
    this.speedMetersPerSecond,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? headingDegrees;
  final double? speedMetersPerSecond;
  final DateTime recordedAt;

  /// Approximate great-circle distance to another position, in meters
  /// (Haversine). Good enough for "have we moved more than X meters" gating;
  /// do **not** use for billing or trip distance.
  double distanceMetersTo(GeoPosition other) {
    const earthRadiusMeters = 6371000.0;
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(other.latitude);
    final dLat = _toRadians(other.latitude - latitude);
    final dLng = _toRadians(other.longitude - longitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  GeoPosition copyWith({
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? headingDegrees,
    double? speedMetersPerSecond,
    DateTime? recordedAt,
  }) {
    return GeoPosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    accuracyMeters,
    headingDegrees,
    speedMetersPerSecond,
    recordedAt,
  ];
}

double _toRadians(double degrees) => degrees * (math.pi / 180.0);
