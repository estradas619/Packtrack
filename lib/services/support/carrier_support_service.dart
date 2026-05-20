import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/package_model.dart';

/// Service for contacting carriers directly.
///
/// Provides phone numbers and support URLs for each carrier,
/// and handles the logic of copying tracking numbers and
/// launching the phone dialer.
class CarrierSupportService {
  CarrierSupportService._();

  /// Carrier support contact information.
  static final Map<String, CarrierContact> _contacts = {
    'FedEx': CarrierContact(
      carrier: 'FedEx',
      phoneUS: '+1-800-463-3339',
      phoneMX: '+52-800-900-1100',
      phoneInternational: '+1-800-463-3339',
      supportUrl: 'https://www.fedex.com/en-us/customer-support.html',
      twitterHandle: '@FedExHelp',
    ),
    'UPS': CarrierContact(
      carrier: 'UPS',
      phoneUS: '+1-800-742-5877',
      phoneMX: '+52-800-742-5877',
      phoneInternational: '+1-800-742-5877',
      supportUrl: 'https://www.ups.com/us/en/support/contact-us.page',
      twitterHandle: '@UPSHelp',
    ),
    'DHL': CarrierContact(
      carrier: 'DHL',
      phoneUS: '+1-800-225-5345',
      phoneMX: '+52-800-765-6345',
      phoneInternational: '+1-800-225-5345',
      supportUrl: 'https://www.dhl.com/us-en/home/customer-service.html',
      twitterHandle: '@DHLMexico',
    ),
    'DHL Express': CarrierContact(
      carrier: 'DHL Express',
      phoneUS: '+1-800-225-5345',
      phoneMX: '+52-800-765-6345',
      phoneInternational: '+1-800-225-5345',
      supportUrl: 'https://www.dhl.com/mx-es/home/customer-service.html',
      twitterHandle: '@DHLMexico',
    ),
    'USPS': CarrierContact(
      carrier: 'USPS',
      phoneUS: '+1-800-275-8777',
      phoneMX: null,
      phoneInternational: '+1-800-275-8777',
      supportUrl: 'https://www.usps.com/help/contact-us.htm',
      twitterHandle: '@USPSHelp',
    ),
    'Amazon': CarrierContact(
      carrier: 'Amazon',
      phoneUS: '+1-888-280-4331',
      phoneMX: '+52-800-288-0013',
      phoneInternational: '+1-888-280-4331',
      supportUrl: 'https://www.amazon.com/gp/help/customer/contact-us',
      twitterHandle: '@AmazonHelp',
    ),
    'Estafeta': CarrierContact(
      carrier: 'Estafeta',
      phoneUS: null,
      phoneMX: '+52-800-378-2338',
      phoneInternational: '+52-800-378-2338',
      supportUrl: 'https://www.estafeta.com/contacto',
      twitterHandle: '@Estafeta',
    ),
    'Correos de México': CarrierContact(
      carrier: 'Correos de México',
      phoneUS: null,
      phoneMX: '+52-800-701-7000',
      phoneInternational: '+52-800-701-7000',
      supportUrl: 'https://www.correosdemexico.gob.mx/',
      twitterHandle: '@CorreosdeMexico',
    ),
    '99 Minutos': CarrierContact(
      carrier: '99 Minutos',
      phoneUS: null,
      phoneMX: '+52-55-4170-8842',
      phoneInternational: '+52-55-4170-8842',
      supportUrl: 'https://www.99minutos.com/contacto',
      twitterHandle: '@99abordo',
    ),
    'J&T Express': CarrierContact(
      carrier: 'J&T Express',
      phoneUS: null,
      phoneMX: '+52-800-953-8835',
      phoneInternational: '+52-800-953-8835',
      supportUrl: 'https://www.jtexpress.mx/',
      twitterHandle: null,
    ),
  };

  /// Check if a package has been stuck (no movement for 48+ hours).
  static bool isPackageStuck(PackageModel package) {
    if (package.isDelivered) return false;

    final lastActivity = _getLastActivityTime(package);
    if (lastActivity == null) return false;

    final hoursSinceActivity =
        DateTime.now().difference(lastActivity).inHours;

    return hoursSinceActivity >= 48;
  }

  /// Get the last activity timestamp for a package.
  static DateTime? _getLastActivityTime(PackageModel package) {
    if (package.events.isEmpty) return package.updatedAt;

    // Get the most recent event timestamp
    final sortedEvents = List.from(package.events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return sortedEvents.first.timestamp;
  }

  /// Get hours since last movement.
  static int getHoursSinceLastMovement(PackageModel package) {
    final lastActivity = _getLastActivityTime(package);
    if (lastActivity == null) return 0;
    return DateTime.now().difference(lastActivity).inHours;
  }

  /// Get contact information for a carrier.
  static CarrierContact? getContact(String carrierName) {
    return _contacts[carrierName];
  }

  /// Copy tracking number to clipboard and open phone dialer.
  static Future<void> contactCarrier({
    required PackageModel package,
    required String region,
  }) async {
    // Step 1: Copy tracking number to clipboard
    await Clipboard.setData(ClipboardData(text: package.trackingNumber));

    // Step 2: Get carrier phone number
    final contact = _contacts[package.carrier];
    if (contact == null) return;

    String? phoneNumber;
    switch (region) {
      case 'US':
        phoneNumber = contact.phoneUS;
        break;
      case 'MX':
        phoneNumber = contact.phoneMX;
        break;
      default:
        phoneNumber = contact.phoneInternational;
    }

    // Fallback to any available number
    phoneNumber ??=
        contact.phoneMX ?? contact.phoneUS ?? contact.phoneInternational;

    if (phoneNumber == null) return;

    // Step 3: Open phone dialer
    final uri = Uri.parse('tel:${phoneNumber.replaceAll(RegExp(r'[^\d+]'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open carrier support website.
  static Future<void> openSupportWebsite(String carrierName) async {
    final contact = _contacts[carrierName];
    if (contact?.supportUrl == null) return;

    final uri = Uri.parse(contact!.supportUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Contact information for a carrier.
class CarrierContact {
  final String carrier;
  final String? phoneUS;
  final String? phoneMX;
  final String? phoneInternational;
  final String? supportUrl;
  final String? twitterHandle;

  const CarrierContact({
    required this.carrier,
    this.phoneUS,
    this.phoneMX,
    this.phoneInternational,
    this.supportUrl,
    this.twitterHandle,
  });

  /// Get the best available phone number.
  String? get bestPhone => phoneMX ?? phoneUS ?? phoneInternational;
}
