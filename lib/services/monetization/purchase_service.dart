import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

/// Service for managing in-app purchases (Premium subscription).
///
/// Handles purchase flow, verification, and subscription status.
class PurchaseService {
  static const String _premiumMonthlyId = 'packtrack_premium_monthly';
  static const String _premiumYearlyId = 'packtrack_premium_yearly';
  static const String _insuranceBasicId = 'packtrack_insurance_basic';
  static const String _insuranceStandardId = 'packtrack_insurance_standard';
  static const String _insurancePremiumId = 'packtrack_insurance_premium';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isPremium = false;

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isPremium => _isPremium;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Initialize the purchase service and load available products.
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        // Handle error
      },
    );

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await _iap.restorePurchases();
  }

  /// Load available products from the store.
  Future<void> _loadProducts() async {
    const productIds = <String>{
      _premiumMonthlyId,
      _premiumYearlyId,
      _insuranceBasicId,
      _insuranceStandardId,
      _insurancePremiumId,
    };

    final response = await _iap.queryProductDetails(productIds);
    _products = response.productDetails;
  }

  // ─── Purchase Flow ─────────────────────────────────────────────────────────

  /// Purchase a premium subscription.
  Future<bool> purchasePremium({bool yearly = false}) async {
    if (!_isAvailable) return false;

    final productId = yearly ? _premiumYearlyId : _premiumMonthlyId;
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Purchase micro-insurance for a package.
  Future<bool> purchaseInsurance(String tier) async {
    if (!_isAvailable) return false;

    String productId;
    switch (tier) {
      case 'basic':
        productId = _insuranceBasicId;
        break;
      case 'standard':
        productId = _insuranceStandardId;
        break;
      case 'premium':
        productId = _insurancePremiumId;
        break;
      default:
        return false;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  // ─── Purchase Handling ─────────────────────────────────────────────────────

  /// Handle purchase updates from the store.
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Show loading indicator
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          // Handle error
          break;
        case PurchaseStatus.canceled:
          // User cancelled
          break;
      }

      // Complete pending purchases
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase and deliver content.
  void _verifyAndDeliver(PurchaseDetails purchase) {
    // In production, verify the purchase receipt with your backend
    if (purchase.productID == _premiumMonthlyId ||
        purchase.productID == _premiumYearlyId) {
      _isPremium = true;
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  /// Dispose of the purchase service.
  void dispose() {
    _subscription?.cancel();
  }
}
