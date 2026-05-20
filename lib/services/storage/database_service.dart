import '../../data/models/package_model.dart';
import '../../data/models/tracking_event_model.dart';

/// Service for managing local database storage.
///
/// This is a stub implementation for demo mode.
/// In production, this would use sqflite or similar local database.
class DatabaseService {
  // In-memory storage for demo mode
  final Map<String, PackageModel> _packages = {};
  final List<Map<String, dynamic>> _searchHistory = [];

  /// Insert or update a package.
  Future<void> upsertPackage(PackageModel package) async {
    _packages[package.id] = package;
  }

  /// Get a package by ID.
  Future<PackageModel?> getPackage(String id) async {
    return _packages[id];
  }

  /// Get all packages.
  Future<List<PackageModel>> getAllPackages() async {
    return _packages.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Delete a package and its events.
  Future<void> deletePackage(String id) async {
    _packages.remove(id);
  }

  /// Insert or update a tracking event.
  Future<void> upsertEvent(String packageId, TrackingEventModel event) async {
    // No-op in demo mode - events are stored within PackageModel
  }

  /// Get all events for a package.
  Future<List<TrackingEventModel>> getEventsForPackage(String packageId) async {
    final package = _packages[packageId];
    return package?.events ?? [];
  }

  /// Add a search history entry.
  Future<void> addSearchEntry({
    required String trackingNumber,
    required String carrier,
    String? lastStatus,
  }) async {
    _searchHistory.removeWhere(
      (entry) => entry['tracking_number'] == trackingNumber,
    );
    _searchHistory.insert(0, {
      'tracking_number': trackingNumber,
      'carrier': carrier,
      'searched_at': DateTime.now().toIso8601String(),
      'last_status': lastStatus,
    });
  }

  /// Get search history.
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 50}) async {
    return _searchHistory.take(limit).toList();
  }

  /// Clear search history.
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
  }

  /// Close the database (no-op in demo mode).
  Future<void> close() async {
    // No-op
  }
}
