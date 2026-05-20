/// Service that auto-detects the carrier based on tracking number patterns.
///
/// Uses regex patterns to identify which courier service a tracking number
/// belongs to. Supports major international and Mexican carriers.
class CarrierDetector {
  CarrierDetector._();

  /// Carrier detection rules with regex patterns.
  static final List<_CarrierPattern> _patterns = [
    // FedEx
    _CarrierPattern(
      carrier: 'FedEx',
      carrierId: 'fedex',
      patterns: [
        RegExp(r'^\d{12}$'),          // 12 digits
        RegExp(r'^\d{15}$'),          // 15 digits
        RegExp(r'^\d{20}$'),          // 20 digits
        RegExp(r'^[0-9]{22}$'),       // 22 digits (FedEx Ground)
      ],
    ),
    // UPS
    _CarrierPattern(
      carrier: 'UPS',
      carrierId: 'ups',
      patterns: [
        RegExp(r'^1Z[A-Z0-9]{16}$', caseSensitive: false),  // 1Z + 16 chars
        RegExp(r'^T\d{10}$'),         // T + 10 digits
        RegExp(r'^\d{9}$'),           // 9 digits
        RegExp(r'^\d{26}$'),          // 26 digits (Mail Innovations)
      ],
    ),
    // DHL
    _CarrierPattern(
      carrier: 'DHL',
      carrierId: 'dhl',
      patterns: [
        RegExp(r'^\d{10}$'),          // 10 digits
        RegExp(r'^\d{11}$'),          // 11 digits
        RegExp(r'^[A-Z]{3}\d{7}$'),   // 3 letters + 7 digits
        RegExp(r'^JD\d{18}$'),        // JD + 18 digits (eCommerce)
        RegExp(r'^\d{4}[ -]?\d{4}[ -]?\d{2}$'), // DHL Express
      ],
    ),
    // USPS
    _CarrierPattern(
      carrier: 'USPS',
      carrierId: 'usps',
      patterns: [
        RegExp(r'^\d{20}$'),                           // 20 digits
        RegExp(r'^\d{22}$'),                           // 22 digits
        RegExp(r'^[A-Z]{2}\d{9}US$', caseSensitive: false), // International
        RegExp(r'^94\d{20}$'),                         // 94 + 20 digits
        RegExp(r'^92\d{20}$'),                         // 92 + 20 digits
        RegExp(r'^420\d{27}$'),                        // 420 + 27 digits
      ],
    ),
    // Amazon Logistics
    _CarrierPattern(
      carrier: 'Amazon',
      carrierId: 'amazon',
      patterns: [
        RegExp(r'^TBA\d{12}$', caseSensitive: false),  // TBA + 12 digits
        RegExp(r'^AMZN', caseSensitive: false),         // AMZN prefix
      ],
    ),
    // Estafeta (Mexico)
    _CarrierPattern(
      carrier: 'Estafeta',
      carrierId: 'estafeta',
      patterns: [
        RegExp(r'^\d{10}$'),           // 10 digits
        RegExp(r'^[0-9]{22}$'),        // 22 digits
        RegExp(r'^806\d{7}$'),         // 806 prefix
      ],
    ),
    // DHL Express Mexico
    _CarrierPattern(
      carrier: 'DHL Express',
      carrierId: 'dhl-express',
      patterns: [
        RegExp(r'^\d{10}$'),
        RegExp(r'^[A-Z]{3}\d{7}$'),
      ],
    ),
    // Correos de Mexico
    _CarrierPattern(
      carrier: 'Correos de México',
      carrierId: 'correos-mexico',
      patterns: [
        RegExp(r'^[A-Z]{2}\d{9}MX$', caseSensitive: false),
        RegExp(r'^MX\d{9}$'),
      ],
    ),
    // 99 Minutos (Mexico)
    _CarrierPattern(
      carrier: '99 Minutos',
      carrierId: '99minutos',
      patterns: [
        RegExp(r'^99M', caseSensitive: false),
      ],
    ),
    // J&T Express
    _CarrierPattern(
      carrier: 'J&T Express',
      carrierId: 'jt-express',
      patterns: [
        RegExp(r'^J[A-Z]\d{10}$', caseSensitive: false),
      ],
    ),
  ];

  /// Detect the carrier from a tracking number.
  /// Returns a [CarrierDetectionResult] with the detected carrier info.
  static CarrierDetectionResult detect(String trackingNumber) {
    final cleaned = trackingNumber.trim().replaceAll(RegExp(r'[\s-]'), '');

    for (final carrierPattern in _patterns) {
      for (final pattern in carrierPattern.patterns) {
        if (pattern.hasMatch(cleaned)) {
          return CarrierDetectionResult(
            detected: true,
            carrier: carrierPattern.carrier,
            carrierId: carrierPattern.carrierId,
            confidence: _calculateConfidence(cleaned, carrierPattern),
          );
        }
      }
    }

    return const CarrierDetectionResult(
      detected: false,
      carrier: 'Unknown',
      carrierId: 'unknown',
      confidence: 0.0,
    );
  }

  /// Detect all possible carriers (some patterns overlap).
  static List<CarrierDetectionResult> detectAll(String trackingNumber) {
    final cleaned = trackingNumber.trim().replaceAll(RegExp(r'[\s-]'), '');
    final results = <CarrierDetectionResult>[];

    for (final carrierPattern in _patterns) {
      for (final pattern in carrierPattern.patterns) {
        if (pattern.hasMatch(cleaned)) {
          results.add(CarrierDetectionResult(
            detected: true,
            carrier: carrierPattern.carrier,
            carrierId: carrierPattern.carrierId,
            confidence: _calculateConfidence(cleaned, carrierPattern),
          ));
          break;
        }
      }
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  static double _calculateConfidence(
      String trackingNumber, _CarrierPattern carrierPattern) {
    // Higher confidence for more specific patterns
    final patternLength = carrierPattern.patterns.first.pattern.length;
    final trackingLength = trackingNumber.length;

    // Patterns with specific prefixes get higher confidence
    if (carrierPattern.patterns.any(
        (p) => p.pattern.contains('^[A-Z]') || p.pattern.contains('^1Z'))) {
      return 0.95;
    }

    // Longer, more specific patterns get higher confidence
    if (trackingLength >= 15) return 0.85;
    if (trackingLength >= 12) return 0.75;

    return 0.60;
  }
}

/// Internal class to hold carrier pattern definitions.
class _CarrierPattern {
  final String carrier;
  final String carrierId;
  final List<RegExp> patterns;

  const _CarrierPattern({
    required this.carrier,
    required this.carrierId,
    required this.patterns,
  });
}

/// Result of a carrier detection attempt.
class CarrierDetectionResult {
  final bool detected;
  final String carrier;
  final String carrierId;
  final double confidence;

  const CarrierDetectionResult({
    required this.detected,
    required this.carrier,
    required this.carrierId,
    required this.confidence,
  });

  @override
  String toString() =>
      'CarrierDetectionResult(carrier: $carrier, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
}
