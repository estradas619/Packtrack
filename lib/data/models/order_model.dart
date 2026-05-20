import 'package_model.dart';

/// Represents a purchase order that groups multiple packages.
class OrderModel {
  final String id;
  final String name;
  final String? storeName;
  final String? storeLogoUrl;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final List<PackageModel> packages;

  const OrderModel({
    required this.id,
    required this.name,
    this.storeName,
    this.storeLogoUrl,
    required this.orderDate,
    this.estimatedDelivery,
    this.packages = const [],
  });

  /// Overall status based on the packages within this order.
  PackageStatus get overallStatus {
    if (packages.isEmpty) return PackageStatus.unknown;

    // If all delivered
    if (packages.every((p) => p.status == PackageStatus.delivered)) {
      return PackageStatus.delivered;
    }

    // If any has exception
    if (packages.any((p) => p.status == PackageStatus.exception)) {
      return PackageStatus.exception;
    }

    // If any is out for delivery
    if (packages.any((p) => p.status == PackageStatus.outForDelivery)) {
      return PackageStatus.outForDelivery;
    }

    // If any is in customs
    if (packages.any((p) => p.status == PackageStatus.inCustoms)) {
      return PackageStatus.inCustoms;
    }

    // If any is in transit
    if (packages.any((p) => p.status == PackageStatus.inTransit)) {
      return PackageStatus.inTransit;
    }

    return PackageStatus.pending;
  }

  /// Number of delivered packages.
  int get deliveredCount =>
      packages.where((p) => p.status == PackageStatus.delivered).length;

  /// Total number of packages.
  int get totalCount => packages.length;

  /// Progress as a fraction (0.0 to 1.0).
  double get progress =>
      totalCount > 0 ? deliveredCount / totalCount : 0.0;

  /// The nearest estimated delivery date among active packages.
  DateTime? get nearestDelivery {
    final activeDates = packages
        .where((p) => p.isActive && p.estimatedDelivery != null)
        .map((p) => p.estimatedDelivery!)
        .toList();
    if (activeDates.isEmpty) return null;
    activeDates.sort();
    return activeDates.first;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'storeName': storeName,
      'storeLogoUrl': storeLogoUrl,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'packages': packages.map((p) => p.toJson()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      storeName: json['storeName'] as String?,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      orderDate: DateTime.parse(json['orderDate'] as String),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      packages: (json['packages'] as List<dynamic>?)
              ?.map((p) => PackageModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  OrderModel copyWith({
    String? id,
    String? name,
    String? storeName,
    String? storeLogoUrl,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    List<PackageModel>? packages,
  }) {
    return OrderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      packages: packages ?? this.packages,
    );
  }
}
