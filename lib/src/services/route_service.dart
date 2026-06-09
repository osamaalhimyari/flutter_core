import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Builds Google Maps `Polyline`s for the route between consecutive points.
/// Falls back to a straight line on routing failures so the map still has
/// something to draw. Pass your Google Maps API key.
class RouteService {
  final String apiKey;
  final PolylinePoints _polylinePoints;

  RouteService({required this.apiKey})
    : _polylinePoints = PolylinePoints(apiKey: apiKey);

  Future<List<Polyline>> buildPolylines(
    List<LatLng> points, {
    Color color = Colors.blue,
    int width = 4,
  }) async {
    if (points.length < 2) return const [];

    final result = <Polyline>[];
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];

      List<LatLng> segment = [from, to];
      try {
        // Uses the stable legacy Directions API on purpose: it returns a plain
        // decoded polyline that maps directly to `List<Polyline>`. Migrating to
        // the Routes API (`getRouteBetweenCoordinatesV2`) is out of scope here.
        // ignore: deprecated_member_use
        final request = PolylineRequest(
          origin: PointLatLng(from.latitude, from.longitude),
          destination: PointLatLng(to.latitude, to.longitude),
          mode: TravelMode.driving,
        );
        final pr = await _polylinePoints.getRouteBetweenCoordinates(
          request: request,
        );
        if (pr.points.isNotEmpty) {
          segment = pr.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
        }
      } catch (_) {
        // Network / quota / quirk — fall back to the straight line.
      }

      result.add(
        Polyline(
          polylineId: PolylineId('route_$i'),
          points: segment,
          width: width,
          color: color,
        ),
      );
    }

    return result;
  }
}
