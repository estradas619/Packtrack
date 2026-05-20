import 'tracking_event_model.dart';

/// Represents the current status of a package.
enum PackageStatus {
  pending,
  inTransit,
  inCustoms,
  outForDelivery,
  delivered,
  exception,
  unknown,
}

/// Extension to provide display-friendly properties for PackageStatus.
extension PackageStatusExtension on PackageStatus {
  String get key {
    switch (this) {
      case PackageStatus.pending:
        return 'pending';
      case PackageStatus.inTransit:
        return 'in_transit';
      case PackageStatus.inCustoms:
        return 'in_customs';
      case PackageStatus.outForDelivery:
        return 'out_for_delivery';
      case PackageStatus.delivered:
        return 'delivered';
      case PackageStatus.exception:
        return 'exception';
      case PackageStatus.unknown:
        return 'unknown';
    }
  }

  static PackageStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PackageStatus.pending;
      case 'in_transit':
        return PackageStatus.inTransit;
      case 'in_customs':
        return PackageStatus.inCustoms;
      case 'out_for_delivery':
        return PackageStatus.outForDelivery;
      case 'delivered':
        return PackageStatus.delivered;
      case 'exception':
        return PackageStatus.exception;
      default:
        return PackageStatus.unknown;
    }
  }

  double get progress {
    switch (this) {
      case PackageStatus.pending:
        return 0.1;
      case PackageStatus.inTransit:
        return 0.4;
      case PackageStatus.inCustoms:
        return 0.5;
      case PackageStatus.outForDelivery:
        return 0.8;
      case PackageStatus.delivered:
        return 1.0;
      case PackageStatus.exception:
        return 0.0;
      case PackageStatus.unknown:
        return 0.0;
    }
  }
}

/// Main data model representing a tracked package.
class PackageModel {
  final String id;
  final String trackingNumber;
  final String carrier;
  final String? carrierLogoUrl;
  final PackageStatus status;
  final String? orderId;
  final String? orderName;
  final String? origin;
  final String? destination;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TrackingEventModel> events;
  final String? description;
  final double? weight;
  final String? dimensions;

  const PackageModel({
    required this.id,
    required this.trackingNumber,
    required this.carrier,
    this.carrierLogoUrl,
    required this.status,
    this.orderId,
    this.orderName,
    this.origin,
    this.destination,
    this.currentLatitude,
    this.currentLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.createdAt,
    required this.updatedAt,
    this.events = const [],
    this.description,
    this.weight,
    this.dimensions,
  });

  /// Whether this package is expected to arrive today.
  bool get isArrivingToday {
    if (estimatedDelivery == null) return false;
    final now = DateTime.now();
    return estimatedDelivery!.year == now.year &&
        estimatedDelivery!.month == now.month &&
        estimatedDelivery!.day == now.day;
  }

  /// Whether this package has been delivered.
  bool get isDelivered => status == PackageStatus.delivered;

  /// Whether this package has an active tracking (not delivered or exception).
  bool get isActive =>
      status != PackageStatus.delivered && status != PackageStatus.exception;

  /// Create a copy of this model with updated fields.
  PackageModel copyWith({
    String? id,
    String? trackingNumber,
    String? carrier,
    String? carrierLogoUrl,
    PackageStatus? status,
    String? orderId,
    String? orderName,
    String? origin,
    String? destination,
    double? currentLatitude,
    double? currentLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrackingEventModel>? events,
    String? description,
    double? weight,
    String? dimensions,
  }) {
    return PackageModel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      carrierLogoUrl: carrierLogoUrl ?? this.carrierLogoUrl,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      orderName: orderName ?? this.orderName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      events: events ?? this.events,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  /// Convert model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'carrierLogoUrl': carrierLogoUrl,
      'status': status.key,
      'orderId': orderId,
      'orderName': orderName,
      'origin': origin,
      'destination': destination,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
      'description': description,
      'weight': weight,
      'dimensions': dimensions,
    };
  }

  /// Create model from JSON map.
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      carrier: json['carrier'] as String,
      carrierLogoUrl: json['carrierLogoUrl'] as String?,
      status: PackageStatusExtension.fromString(json['status'] as String),
      orderId: json['orderId'] as String?,
      orderName: json['orderName'] as String?,
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      events: (json['events'] as List<dynamic>?)
              ?.map((e) =>
                  TrackingEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
    );
  }
}
