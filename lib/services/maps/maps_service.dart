import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

/// Service for interacting with Google Maps APIs.
///
/// Provides geocoding, directions, and distance calculations
/// for package tracking visualization.
class MapsService {
  final http.Client _client;

  MapsService({http.Client? client}) : _client = client ?? http.Client();

  /// Get directions between two points.
  /// Returns a list of LatLng points for the polyline.
  Future<List<Map<String, double>>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&key=${AppConstants.googleMapsApiKey}',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final points = routes[0]['overview_polyline']['points'] as String;
          return _decodePolyline(points);
        }
      }
    } catch (e) {
      // Silently fail and return empty list
    }

    return [];
  }

  /// Geocode an address to coordinates.
  Future<Map<String, double>?> geocodeAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(address)}'
      '&key=${AppConstants.googleMapsApiKey}',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return {
            'lat': (location['lat'] as num).toDouble(),
            'lng': (location['lng'] as num).toDouble(),
          };
        }
      }
    } catch (e) {
      // Silently fail
    }

    return null;
  }

  /// Calculate distance between two points in kilometers using Haversine formula.
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Decode a Google Maps encoded polyline string.
  List<Map<String, double>> _decodePolyline(String encoded) {
    final points = <Map<String, double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      // Decode latitude
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add({
        'lat': lat / 1E5,
        'lng': lng / 1E5,
      });
    }

    return points;
  }

  void dispose() {
    _client.close();
  }
}
