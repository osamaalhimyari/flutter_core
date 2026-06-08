import 'dart:math';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/search_prediction.dart';
import 'locale_service.dart';

/// Forward search backed by Google Places Autocomplete + Place Details.
///
/// Autocomplete returns up to ~5 partial-match predictions per keystroke;
/// [latLngFromPrediction] resolves the chosen one. Requires the **Places API**
/// enabled on the same Google Cloud project as your Maps key. Session tokens
/// batch one autocomplete burst + the follow-up details call into one billed
/// session.
class SearchService {
  final LocaleService _localeService;
  final String apiKey;
  final Dio _dio;

  String? _sessionToken;

  SearchService({
    required this.apiKey,
    required LocaleService localeService,
    Dio? dio,
  }) : _localeService = localeService,
       _dio = dio ?? Dio();

  Future<List<SearchPrediction>> searchLocations(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    _sessionToken ??= _newSessionToken();

    final res = await _dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': q,
        'key': apiKey,
        'language': _localeService.currentLanguageCode,
        'sessiontoken': _sessionToken,
      },
    );

    final data = res.data ?? const <String, dynamic>{};
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status == 'ZERO_RESULTS') return const [];
    if (status != 'OK') {
      throw Exception('Places autocomplete failed: $status');
    }

    final predictions = (data['predictions'] as List?) ?? const [];
    return predictions
        .whereType<Map<String, dynamic>>()
        .map(_predictionFromJson)
        .toList(growable: false);
  }

  Future<LatLng?> latLngFromPrediction(SearchPrediction p) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': p.placeId,
        'fields': 'geometry/location',
        'key': apiKey,
        'language': _localeService.currentLanguageCode,
        if (_sessionToken != null) 'sessiontoken': _sessionToken,
      },
    );
    // Session ends after the details call — next search mints a new token.
    _sessionToken = null;

    final data = res.data ?? const <String, dynamic>{};
    final result = data['result'];
    if (result is! Map) return null;
    final geometry = result['geometry'];
    if (geometry is! Map) return null;
    final location = geometry['location'];
    if (location is! Map) return null;
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  static SearchPrediction _predictionFromJson(Map<String, dynamic> json) {
    final structured =
        (json['structured_formatting'] as Map?) ?? const <String, dynamic>{};
    final description = json['description'] as String? ?? '';
    return SearchPrediction(
      placeId: json['place_id'] as String? ?? '',
      mainText: structured['main_text'] as String? ?? description,
      secondaryText: structured['secondary_text'] as String? ?? '',
      description: description,
    );
  }

  static final _rng = Random.secure();
  static String _newSessionToken() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
