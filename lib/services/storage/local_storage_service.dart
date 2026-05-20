import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/package_model.dart';
import '../../data/models/search_entry_model.dart';
import '../../data/models/order_model.dart';

/// Service for managing local data persistence.
///
/// Uses SharedPreferences for lightweight data (search history, preferences)
/// and provides methods for caching package/order data locally.
class LocalStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Search History ────────────────────────────────────────────────────────

  /// Save a search entry to history.
  Future<void> saveSearchEntry(SearchEntryModel entry) async {
    final sp = await prefs;
    final history = await getSearchHistory();
    
    // Remove duplicate if exists
    history.removeWhere((e) => e.trackingNumber == entry.trackingNumber);
    
    // Add to beginning
    history.insert(0, entry);
    
    // Trim to max size
    if (history.length > AppConstants.maxSearchHistory) {
      history.removeRange(AppConstants.maxSearchHistory, history.length);
    }

    final jsonList = history.map((e) => json.encode(e.toJson())).toList();
    await sp.setStringList(AppConstants.keySearchHistory, jsonList);
  }

  /// Get all search history entries.
  Future<List<SearchEntryModel>> getSearchHistory() async {
    final sp = await prefs;
    final jsonList = sp.getStringList(AppConstants.keySearchHistory) ?? [];
    
    return jsonList
        .map((jsonStr) => SearchEntryModel.fromJson(
            json.decode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  /// Clear all search history.
  Future<void> clearSearchHistory() async {
    final sp = await prefs;
    await sp.remove(AppConstants.keySearchHistory);
  }

  /// Delete a specific search entry.
  Future<void> deleteSearchEntry(String trackingNumber) async {
    final sp = await prefs;
    final history = await getSearchHistory();
    history.removeWhere((e) => e.trackingNumber == trackingNumber);
    
    final jsonList = history.map((e) => json.encode(e.toJson())).toList();
    await sp.setStringList(AppConstants.keySearchHistory, jsonList);
  }

  // ─── Cached Packages ───────────────────────────────────────────────────────

  /// Cache a package locally for offline access.
  Future<void> cachePackage(PackageModel package) async {
    final sp = await prefs;
    final cached = await getCachedPackages();
    
    // Update or add
    final index = cached.indexWhere((p) => p.id == package.id);
    if (index >= 0) {
      cached[index] = package;
    } else {
      cached.insert(0, package);
    }

    // Trim
    if (cached.length > AppConstants.maxRecentPackages) {
      cached.removeRange(AppConstants.maxRecentPackages, cached.length);
    }

    final jsonList = cached.map((p) => json.encode(p.toJson())).toList();
    await sp.setStringList('cached_packages', jsonList);
  }

  /// Get all cached packages.
  Future<List<PackageModel>> getCachedPackages() async {
    final sp = await prefs;
    final jsonList = sp.getStringList('cached_packages') ?? [];
    
    return jsonList
        .map((jsonStr) => PackageModel.fromJson(
            json.decode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  /// Remove a cached package.
  Future<void> removeCachedPackage(String packageId) async {
    final sp = await prefs;
    final cached = await getCachedPackages();
    cached.removeWhere((p) => p.id == packageId);
    
    final jsonList = cached.map((p) => json.encode(p.toJson())).toList();
    await sp.setStringList('cached_packages', jsonList);
  }

  // ─── Cached Orders ─────────────────────────────────────────────────────────

  /// Cache an order locally.
  Future<void> cacheOrder(OrderModel order) async {
    final sp = await prefs;
    final cached = await getCachedOrders();
    
    final index = cached.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      cached[index] = order;
    } else {
      cached.insert(0, order);
    }

    final jsonList = cached.map((o) => json.encode(o.toJson())).toList();
    await sp.setStringList('cached_orders', jsonList);
  }

  /// Get all cached orders.
  Future<List<OrderModel>> getCachedOrders() async {
    final sp = await prefs;
    final jsonList = sp.getStringList('cached_orders') ?? [];
    
    return jsonList
        .map((jsonStr) => OrderModel.fromJson(
            json.decode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  // ─── Locale Preference ─────────────────────────────────────────────────────

  /// Save the user's preferred locale.
  Future<void> saveLocale(String languageCode) async {
    final sp = await prefs;
    await sp.setString(AppConstants.keyLocale, languageCode);
  }

  /// Get the saved locale preference.
  Future<String?> getLocale() async {
    final sp = await prefs;
    return sp.getString(AppConstants.keyLocale);
  }

  // ─── General ───────────────────────────────────────────────────────────────

  /// Check if onboarding has been completed.
  Future<bool> isOnboardingComplete() async {
    final sp = await prefs;
    return sp.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> setOnboardingComplete() async {
    final sp = await prefs;
    await sp.setBool(AppConstants.keyOnboardingComplete, true);
  }
}
