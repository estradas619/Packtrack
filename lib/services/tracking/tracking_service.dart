import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../data/models/package_model.dart';
import '../../data/models/tracking_event_model.dart';
import 'carrier_detector.dart';

/// Service responsible for fetching tracking information from carrier APIs.
///
/// This service provides a unified interface to query multiple carrier APIs
/// and return standardized tracking data.
class TrackingService {
  final http.Client _client;
  final String? _apiKey;

  TrackingService({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey;

  /// Track a package by its tracking number.
  /// Auto-detects the carrier if not specified.
  Future<PackageModel?> trackPackage({
    required String trackingNumber,
    String? carrierId,
  }) async {
    // Auto-detect carrier if not provided
    final detectedCarrier = carrierId ??
        CarrierDetector.detect(trackingNumber).carrierId;

    try {
      // Attempt to fetch from the unified tracking API
      final result = await _fetchFromUnifiedApi(
        trackingNumber: trackingNumber,
        carrierId: detectedCarrier,
      );
      return result;
    } catch (e) {
      // Fallback: try carrier-specific API
      try {
        return await _fetchFromCarrierApi(
          trackingNumber: trackingNumber,
          carrierId: detectedCarrier,
        );
      } catch (e) {
        return null;
      }
    }
  }

  /// Fetch tracking data from a unified multi-carrier API (e.g., TrackingMore, AfterShip).
  Future<PackageModel?> _fetchFromUnifiedApi({
    required String trackingNumber,
    required String carrierId,
  }) async {
    final url = Uri.parse(
      'https://api.trackingmore.com/v4/trackings/get',
    );

    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Tracking-Api-Key': _apiKey ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseUnifiedResponse(data, trackingNumber, carrierId);
    }

    return null;
  }

  /// Fetch from carrier-specific API endpoints.
  Future<PackageModel?> _fetchFromCarrierApi({
    required String trackingNumber,
    required String carrierId,
  }) async {
    // This method would contain carrier-specific API calls.
    // For now, we return null and rely on the unified API.
    // In production, implement specific endpoints for each carrier.
    return null;
  }

  /// Parse unified API response into our PackageModel.
  PackageModel? _parseUnifiedResponse(
    Map<String, dynamic> data,
    String trackingNumber,
    String carrierId,
  ) {
    try {
      final trackingData = data['data'] as Map<String, dynamic>?;
      if (trackingData == null) return null;

      final events = (trackingData['origin_info']?['trackinfo'] as List?)
              ?.map((event) => TrackingEventModel(
                    id: event['checkpoint_date'] ?? '',
                    description: event['tracking_detail'] ?? '',
                    location: event['location'] ?? '',
                    timestamp: DateTime.tryParse(
                            event['checkpoint_date'] ?? '') ??
                        DateTime.now(),
                    status: event['checkpoint_delivery_status'] ?? '',
                  ))
              .toList() ??
          [];

      return PackageModel(
        id: trackingNumber,
        trackingNumber: trackingNumber,
        carrier: carrierId,
        status: _mapStatus(trackingData['delivery_status'] as String?),
        origin: trackingData['origin'] as String?,
        destination: trackingData['destination'] as String?,
        estimatedDelivery: trackingData['expected_delivery'] != null
            ? DateTime.tryParse(trackingData['expected_delivery'] as String)
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        events: events,
      );
    } catch (e) {
      return null;
    }
  }

  /// Map API status strings to our PackageStatus enum.
  PackageStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'transit':
      case 'in_transit':
      case 'intransit':
        return PackageStatus.inTransit;
      case 'pickup':
      case 'pending':
        return PackageStatus.pending;
      case 'delivered':
        return PackageStatus.delivered;
      case 'undelivered':
      case 'exception':
      case 'alert':
        return PackageStatus.exception;
      case 'expired':
      case 'notfound':
        return PackageStatus.unknown;
      default:
        return PackageStatus.unknown;
    }
  }

  /// Register a new tracking number for monitoring.
  Future<bool> registerTracking({
    required String trackingNumber,
    required String carrierId,
  }) async {
    final url = Uri.parse(
      'https://api.trackingmore.com/v4/trackings/create',
    );

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Tracking-Api-Key': _apiKey ?? '',
        },
        body: json.encode({
          'tracking_number': trackingNumber,
          'courier_code': carrierId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
