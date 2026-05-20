/// Application-wide constants for PackTrack.
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'PackTrack';
  static const String appVersion = '1.0.0';

  // ─── API Keys (Replace with actual keys in production) ─────────────────────
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // ─── Tracking API Endpoints ────────────────────────────────────────────────
  static const String trackingBaseUrl = 'https://api.trackingmore.com/v4';
  static const String aftershipBaseUrl = 'https://api.aftership.com/v4';

  // ─── Carrier Identifiers ───────────────────────────────────────────────────
  static const String carrierFedEx = 'fedex';
  static const String carrierUPS = 'ups';
  static const String carrierDHL = 'dhl';
  static const String carrierUSPS = 'usps';
  static const String carrierAmazon = 'amazon';
  static const String carrierEstafeta = 'estafeta';
  static const String carrier99Minutos = '99minutos';
  static const String carrierDHLExpress = 'dhl-express';
  static const String carrierCorreosMexico = 'correos-mexico';

  // ─── Storage Keys ──────────────────────────────────────────────────────────
  static const String keyLocale = 'app_locale';
  static const String keySearchHistory = 'search_history';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';

  // ─── Limits ────────────────────────────────────────────────────────────────
  static const int maxSearchHistory = 50;
  static const int maxRecentPackages = 20;
  static const int refreshIntervalMinutes = 15;

  // ─── Animation Durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
}
