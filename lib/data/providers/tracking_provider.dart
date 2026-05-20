import 'package:flutter/foundation.dart';

import '../models/package_model.dart';
import '../models/order_model.dart';
import '../models/tracking_event_model.dart';
import '../../services/tracking/tracking_service.dart';
import '../../services/tracking/carrier_detector.dart';
import '../../services/storage/local_storage_service.dart';

/// Provider that manages the state of all tracked packages and orders.
class TrackingProvider extends ChangeNotifier {
  final TrackingService _trackingService = TrackingService();
  final LocalStorageService _storageService = LocalStorageService();

  List<PackageModel> _packages = [];
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  PackageModel? _selectedPackage;

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<PackageModel> get packages => _packages;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PackageModel? get selectedPackage => _selectedPackage;

  /// Get the package that is closest to being delivered today.
  PackageModel? get nearestDeliveryToday {
    final todayPackages = _packages
        .where((p) => p.isArrivingToday && p.isActive)
        .toList();
    if (todayPackages.isEmpty) {
      // Return the one with the nearest estimated delivery
      final active = _packages.where((p) => p.isActive).toList();
      if (active.isEmpty) return null;
      active.sort((a, b) {
        if (a.estimatedDelivery == null) return 1;
        if (b.estimatedDelivery == null) return -1;
        return a.estimatedDelivery!.compareTo(b.estimatedDelivery!);
      });
      return active.first;
    }
    return todayPackages.first;
  }

  /// Get active (non-delivered) packages.
  List<PackageModel> get activePackages =>
      _packages.where((p) => p.isActive).toList();

  /// Get delivered packages.
  List<PackageModel> get deliveredPackages =>
      _packages.where((p) => p.isDelivered).toList();

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Initialize provider by loading cached data.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _packages = await _storageService.getCachedPackages();
      _orders = await _storageService.getCachedOrders();

      // If no cached data, load demo data for showcase
      if (_packages.isEmpty) {
        _loadDemoData();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Track a new package by tracking number.
  Future<PackageModel?> trackNewPackage(String trackingNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Auto-detect carrier
      final detection = CarrierDetector.detect(trackingNumber);

      // Try to fetch from API
      final result = await _trackingService.trackPackage(
        trackingNumber: trackingNumber,
        carrierId: detection.carrierId,
      );

      if (result != null) {
        // Add to packages list
        _packages.insert(0, result);
        await _storageService.cachePackage(result);
        _isLoading = false;
        notifyListeners();
        return result;
      } else {
        // Create a placeholder package with detected carrier
        final placeholder = PackageModel(
          id: trackingNumber,
          trackingNumber: trackingNumber,
          carrier: detection.carrier,
          status: PackageStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _packages.insert(0, placeholder);
        await _storageService.cachePackage(placeholder);
        _isLoading = false;
        notifyListeners();
        return placeholder;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Refresh tracking data for a specific package.
  Future<void> refreshPackage(String packageId) async {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index < 0) return;

    try {
      final result = await _trackingService.trackPackage(
        trackingNumber: _packages[index].trackingNumber,
      );

      if (result != null) {
        _packages[index] = result;
        await _storageService.cachePackage(result);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refresh all active packages.
  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    for (final package in activePackages) {
      await refreshPackage(package.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Select a package for detail view.
  void selectPackage(PackageModel package) {
    _selectedPackage = package;
    notifyListeners();
  }

  /// Remove a package from tracking.
  Future<void> removePackage(String packageId) async {
    _packages.removeWhere((p) => p.id == packageId);
    await _storageService.removeCachedPackage(packageId);
    notifyListeners();
  }

  /// Group packages into orders.
  void _groupPackagesIntoOrders() {
    final orderMap = <String, List<PackageModel>>{};

    for (final package in _packages) {
      final orderId = package.orderId ?? 'ungrouped_${package.id}';
      orderMap.putIfAbsent(orderId, () => []).add(package);
    }

    _orders = orderMap.entries.map((entry) {
      final packages = entry.value;
      final firstPackage = packages.first;
      return OrderModel(
        id: entry.key,
        name: firstPackage.orderName ?? 'Order ${entry.key.substring(0, 8)}',
        orderDate: firstPackage.createdAt,
        estimatedDelivery: firstPackage.estimatedDelivery,
        packages: packages,
      );
    }).toList();

    // Sort: active orders first, then by estimated delivery
    _orders.sort((a, b) {
      if (a.overallStatus == PackageStatus.delivered &&
          b.overallStatus != PackageStatus.delivered) return 1;
      if (a.overallStatus != PackageStatus.delivered &&
          b.overallStatus == PackageStatus.delivered) return -1;
      final aDate = a.nearestDelivery ?? DateTime(2099);
      final bDate = b.nearestDelivery ?? DateTime(2099);
      return aDate.compareTo(bDate);
    });
  }

  /// Load demo data for showcase purposes.
  void _loadDemoData() {
    final now = DateTime.now();

    _packages = [
      PackageModel(
        id: 'pkg_001',
        trackingNumber: '1Z999AA10123456784',
        carrier: 'UPS',
        status: PackageStatus.outForDelivery,
        orderId: 'order_001',
        orderName: 'MacBook Pro 16"',
        origin: 'Shanghai, China',
        destination: 'Ciudad de México, MX',
        currentLatitude: 19.4326,
        currentLongitude: -99.1332,
        destinationLatitude: 19.4260,
        destinationLongitude: -99.1707,
        estimatedDelivery: now.add(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        events: [
          TrackingEventModel(
            id: 'evt_001_1',
            description: 'Package picked up',
            location: 'Shanghai, China',
            timestamp: now.subtract(const Duration(days: 5)),
            status: 'picked_up',
            latitude: 31.2304,
            longitude: 121.4737,
          ),
          TrackingEventModel(
            id: 'evt_001_2',
            description: 'In transit - Departed facility',
            location: 'Shanghai Airport, China',
            timestamp: now.subtract(const Duration(days: 4)),
            status: 'in_transit',
            latitude: 31.1443,
            longitude: 121.8083,
          ),
          TrackingEventModel(
            id: 'evt_001_3',
            description: 'Arrived at customs',
            location: 'CDMX Airport, Mexico',
            timestamp: now.subtract(const Duration(days: 2)),
            status: 'in_customs',
            latitude: 19.4361,
            longitude: -99.0719,
          ),
          TrackingEventModel(
            id: 'evt_001_4',
            description: 'Cleared customs',
            location: 'CDMX, Mexico',
            timestamp: now.subtract(const Duration(days: 1)),
            status: 'in_transit',
            latitude: 19.4326,
            longitude: -99.1332,
          ),
          TrackingEventModel(
            id: 'evt_001_5',
            description: 'Out for delivery',
            location: 'Ciudad de México, MX',
            timestamp: now.subtract(const Duration(hours: 2)),
            status: 'out_for_delivery',
            latitude: 19.4300,
            longitude: -99.1500,
          ),
        ],
      ),
      PackageModel(
        id: 'pkg_002',
        trackingNumber: '794644790132',
        carrier: 'FedEx',
        status: PackageStatus.inTransit,
        orderId: 'order_002',
        orderName: 'AirPods Pro',
        origin: 'Memphis, TN, USA',
        destination: 'Monterrey, MX',
        currentLatitude: 25.6866,
        currentLongitude: -100.3161,
        destinationLatitude: 25.6714,
        destinationLongitude: -100.3090,
        estimatedDelivery: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        events: [
          TrackingEventModel(
            id: 'evt_002_1',
            description: 'Shipment information sent to FedEx',
            location: 'Memphis, TN',
            timestamp: now.subtract(const Duration(days: 3)),
            status: 'pending',
          ),
          TrackingEventModel(
            id: 'evt_002_2',
            description: 'Picked up',
            location: 'Memphis, TN',
            timestamp: now.subtract(const Duration(days: 2, hours: 12)),
            status: 'picked_up',
          ),
          TrackingEventModel(
            id: 'evt_002_3',
            description: 'In transit',
            location: 'Dallas, TX',
            timestamp: now.subtract(const Duration(days: 1)),
            status: 'in_transit',
            latitude: 32.7767,
            longitude: -96.7970,
          ),
        ],
      ),
      PackageModel(
        id: 'pkg_003',
        trackingNumber: '4206700092612927005301',
        carrier: 'USPS',
        status: PackageStatus.inCustoms,
        orderId: 'order_002',
        orderName: 'iPhone Case',
        origin: 'Los Angeles, CA, USA',
        destination: 'Monterrey, MX',
        estimatedDelivery: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        events: [
          TrackingEventModel(
            id: 'evt_003_1',
            description: 'Accepted at USPS facility',
            location: 'Los Angeles, CA',
            timestamp: now.subtract(const Duration(days: 7)),
            status: 'pending',
          ),
          TrackingEventModel(
            id: 'evt_003_2',
            description: 'In transit to destination',
            location: 'International Distribution Center',
            timestamp: now.subtract(const Duration(days: 4)),
            status: 'in_transit',
          ),
          TrackingEventModel(
            id: 'evt_003_3',
            description: 'Held at customs',
            location: 'Laredo, TX - Mexico Border',
            timestamp: now.subtract(const Duration(days: 1)),
            status: 'in_customs',
          ),
        ],
      ),
      PackageModel(
        id: 'pkg_004',
        trackingNumber: 'JD014600003204140185',
        carrier: 'DHL',
        status: PackageStatus.delivered,
        orderId: 'order_003',
        orderName: 'Kindle Paperwhite',
        origin: 'Shenzhen, China',
        destination: 'Guadalajara, MX',
        estimatedDelivery: now.subtract(const Duration(days: 1)),
        actualDelivery: now.subtract(const Duration(days: 1, hours: 3)),
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 1)),
        events: [
          TrackingEventModel(
            id: 'evt_004_1',
            description: 'Shipment picked up',
            location: 'Shenzhen, China',
            timestamp: now.subtract(const Duration(days: 14)),
            status: 'picked_up',
          ),
          TrackingEventModel(
            id: 'evt_004_2',
            description: 'Departed facility',
            location: 'Hong Kong',
            timestamp: now.subtract(const Duration(days: 12)),
            status: 'in_transit',
          ),
          TrackingEventModel(
            id: 'evt_004_3',
            description: 'Arrived at destination country',
            location: 'Mexico City, MX',
            timestamp: now.subtract(const Duration(days: 5)),
            status: 'in_customs',
          ),
          TrackingEventModel(
            id: 'evt_004_4',
            description: 'Delivered',
            location: 'Guadalajara, MX',
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
            status: 'delivered',
          ),
        ],
      ),
    ];

    _groupPackagesIntoOrders();
  }
}
