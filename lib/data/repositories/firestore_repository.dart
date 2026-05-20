import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/package_model.dart';
import '../models/order_model.dart';

/// Repository for syncing package data with Firebase Firestore.
///
/// Provides CRUD operations for packages and orders stored in the cloud,
/// enabling cross-device synchronization and backup.
class FirestoreRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestoreRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  // ─── Collection References ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _packagesRef =>
      _firestore.collection('users').doc(_userId).collection('packages');

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('users').doc(_userId).collection('orders');

  // ─── Package Operations ────────────────────────────────────────────────────

  /// Save or update a package in Firestore.
  Future<void> savePackage(PackageModel package) async {
    await _packagesRef.doc(package.id).set(
      package.toJson(),
      SetOptions(merge: true),
    );
  }

  /// Get a package by ID.
  Future<PackageModel?> getPackage(String packageId) async {
    final doc = await _packagesRef.doc(packageId).get();
    if (!doc.exists) return null;
    return PackageModel.fromJson(doc.data()!);
  }

  /// Get all packages for the current user.
  Future<List<PackageModel>> getAllPackages() async {
    final snapshot = await _packagesRef
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PackageModel.fromJson(doc.data()))
        .toList();
  }

  /// Get active (non-delivered) packages.
  Future<List<PackageModel>> getActivePackages() async {
    final snapshot = await _packagesRef
        .where('status', isNotEqualTo: 'delivered')
        .orderBy('status')
        .orderBy('estimatedDelivery')
        .get();

    return snapshot.docs
        .map((doc) => PackageModel.fromJson(doc.data()))
        .toList();
  }

  /// Delete a package.
  Future<void> deletePackage(String packageId) async {
    await _packagesRef.doc(packageId).delete();
  }

  /// Listen to real-time updates for all packages.
  Stream<List<PackageModel>> watchPackages() {
    return _packagesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PackageModel.fromJson(doc.data()))
            .toList());
  }

  /// Listen to real-time updates for a specific package.
  Stream<PackageModel?> watchPackage(String packageId) {
    return _packagesRef.doc(packageId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PackageModel.fromJson(doc.data()!);
    });
  }

  // ─── Order Operations ──────────────────────────────────────────────────────

  /// Save or update an order.
  Future<void> saveOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(
      order.toJson(),
      SetOptions(merge: true),
    );
  }

  /// Get all orders.
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _ordersRef
        .orderBy('orderDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }

  /// Delete an order.
  Future<void> deleteOrder(String orderId) async {
    await _ordersRef.doc(orderId).delete();
  }

  /// Listen to real-time order updates.
  Stream<List<OrderModel>> watchOrders() {
    return _ordersRef
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }
}
