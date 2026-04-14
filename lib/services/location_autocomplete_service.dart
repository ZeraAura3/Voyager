// lib/services/location_autocomplete_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a single location suggestion from Nominatim
class LocationSuggestion {
  final String displayName;
  final String shortName;
  final double lat;
  final double lng;
  final String placeId;

  LocationSuggestion({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lng,
    required this.placeId,
  });

  factory LocationSuggestion.fromNominatim(Map<String, dynamic> json) {
    // Build a short, readable name from the address components
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final parts = <String>[];

    // Primary name: city/town/village/suburb
    final primary = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['suburb'] ??
        address['hamlet'] ??
        address['neighbourhood'] ??
        '';
    if (primary.toString().isNotEmpty) parts.add(primary.toString());

    // Secondary: county or district for disambiguation
    final secondary = address['county'] ?? address['state_district'] ?? '';
    if (secondary.toString().isNotEmpty) parts.add(secondary.toString());

    // State for further disambiguation
    final state = address['state'] ?? '';
    if (state.toString().isNotEmpty) parts.add(state.toString());

    final shortName =
        parts.isNotEmpty ? parts.join(', ') : json['display_name'] ?? '';

    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      shortName: shortName,
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lon'].toString()),
      placeId: json['place_id']?.toString() ?? '',
    );
  }

  @override
  String toString() => shortName;
}

/// Service for searching locations using Nominatim (OpenStreetMap) API
class LocationAutocompleteService {
  static const String _baseUrl =
      'https://nominatim.openstreetmap.org/search';
  static const String _userAgent =
      'VoyagerApp/1.0 (B23394@students.iitmandi.ac.in)';

  /// Search for locations matching the given query.
  /// Returns up to [limit] suggestions.
  /// Prioritises results in India via [countryCodes] but does not exclude others.
  Future<List<LocationSuggestion>> searchLocations(
    String query, {
    int limit = 5,
    String countryCodes = 'in',
  }) async {
    if (query.trim().length < 2) return [];

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': query.trim(),
        'format': 'json',
        'addressdetails': '1',
        'limit': limit.toString(),
        'countrycodes': countryCodes,
      });

      final response = await http.get(uri, headers: {
        'User-Agent': _userAgent,
      });

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) =>
              LocationSuggestion.fromNominatim(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
