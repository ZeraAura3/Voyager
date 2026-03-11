import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  static final Map<String, Locale> supportedLanguages = {
    'English': const Locale('en'),
    'Hindi': const Locale('hi'),
    'Spanish': const Locale('es'),
    'French': const Locale('fr'),
    'German': const Locale('de'),
    'Chinese': const Locale('zh'),
  };

  static final Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
  };

  LocaleProvider(this._locale);

  static Future<LocaleProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    return LocaleProvider(Locale(localeCode));
  }

  Future<void> setLocale(String languageName) async {
    final newLocale = supportedLanguages[languageName];
    if (newLocale != null && newLocale != _locale) {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  String get currentLanguageName {
    return languageNames[_locale.languageCode] ?? 'English';
  }
}
