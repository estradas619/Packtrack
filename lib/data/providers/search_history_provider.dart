import 'package:flutter/foundation.dart';

import '../models/search_entry_model.dart';
import '../../services/storage/local_storage_service.dart';
import '../../services/tracking/carrier_detector.dart';

/// Provider that manages search history state.
class SearchHistoryProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  List<SearchEntryModel> _history = [];
  bool _isLoading = false;

  List<SearchEntryModel> get history => _history;
  bool get isLoading => _isLoading;

  /// Load search history from local storage.
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _history = await _storageService.getSearchHistory();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new search entry.
  Future<void> addEntry(String trackingNumber) async {
    final detection = CarrierDetector.detect(trackingNumber);

    final entry = SearchEntryModel(
      trackingNumber: trackingNumber,
      carrier: detection.carrier,
      searchedAt: DateTime.now(),
    );

    await _storageService.saveSearchEntry(entry);
    _history.insert(0, entry);
    
    // Remove duplicates
    final seen = <String>{};
    _history.removeWhere((e) => !seen.add(e.trackingNumber));

    notifyListeners();
  }

  /// Remove a specific entry.
  Future<void> removeEntry(String trackingNumber) async {
    await _storageService.deleteSearchEntry(trackingNumber);
    _history.removeWhere((e) => e.trackingNumber == trackingNumber);
    notifyListeners();
  }

  /// Clear all history.
  Future<void> clearAll() async {
    await _storageService.clearSearchHistory();
    _history.clear();
    notifyListeners();
  }
}
