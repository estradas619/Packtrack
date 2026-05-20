/// Represents a single search history entry.
class SearchEntryModel {
  final String trackingNumber;
  final String carrier;
  final DateTime searchedAt;
  final String? lastStatus;

  const SearchEntryModel({
    required this.trackingNumber,
    required this.carrier,
    required this.searchedAt,
    this.lastStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'searchedAt': searchedAt.toIso8601String(),
      'lastStatus': lastStatus,
    };
  }

  factory SearchEntryModel.fromJson(Map<String, dynamic> json) {
    return SearchEntryModel(
      trackingNumber: json['trackingNumber'] as String,
      carrier: json['carrier'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      lastStatus: json['lastStatus'] as String?,
    );
  }
}
