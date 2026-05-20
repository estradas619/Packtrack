import 'package:flutter/material.dart';
import '../../services/storage/local_storage_service.dart';

/// Provider that manages the current locale/language of the app.
class LocaleProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  Locale _locale = const Locale('es', 'MX');

  Locale get locale => _locale;

  /// Available languages with their display names.
  static const Map<String, LocaleInfo> supportedLocales = {
    'en': LocaleInfo(
      locale: Locale('en', 'US'),
      name: 'English',
      flag: '🇺🇸',
    ),
    'es': LocaleInfo(
      locale: Locale('es', 'MX'),
      name: 'Español',
      flag: '🇲🇽',
    ),
    'pt': LocaleInfo(
      locale: Locale('pt', 'BR'),
      name: 'Português',
      flag: '🇧🇷',
    ),
    'fr': LocaleInfo(
      locale: Locale('fr', 'FR'),
      name: 'Français',
      flag: '🇫🇷',
    ),
    'de': LocaleInfo(
      locale: Locale('de', 'DE'),
      name: 'Deutsch',
      flag: '🇩🇪',
    ),
  };

  LocaleProvider() {
    _loadSavedLocale();
  }

  /// Load the saved locale preference.
  Future<void> _loadSavedLocale() async {
    final savedCode = await _storageService.getLocale();
    if (savedCode != null && supportedLocales.containsKey(savedCode)) {
      _locale = supportedLocales[savedCode]!.locale;
      notifyListeners();
    }
  }

  /// Change the app locale.
  Future<void> setLocale(String languageCode) async {
    if (!supportedLocales.containsKey(languageCode)) return;

    _locale = supportedLocales[languageCode]!.locale;
    await _storageService.saveLocale(languageCode);
    notifyListeners();
  }

  /// Get the current locale info.
  LocaleInfo get currentLocaleInfo =>
      supportedLocales[_locale.languageCode] ??
      supportedLocales['es']!;
}

/// Information about a supported locale.
class LocaleInfo {
  final Locale locale;
  final String name;
  final String flag;

  const LocaleInfo({
    required this.locale,
    required this.name,
    required this.flag,
  });
}
