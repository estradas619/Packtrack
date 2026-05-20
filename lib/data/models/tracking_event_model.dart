/// Represents a single tracking event in the package journey.
class TrackingEventModel {
  final String id;
  final String description;
  final String location;
  final DateTime timestamp;
  final String status;
  final double? latitude;
  final double? longitude;

  const TrackingEventModel({
    required this.id,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.status,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  TrackingEventModel copyWith({
    String? id,
    String? description,
    String? location,
    DateTime? timestamp,
    String? status,
    double? latitude,
    double? longitude,
  }) {
    return TrackingEventModel(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
