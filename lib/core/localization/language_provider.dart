import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/preferences_service.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale?>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<Locale?> {
  final PreferencesService _prefs;

  LanguageNotifier(this._prefs) : super(_parseLocale(_prefs.locale));

  static Locale? _parseLocale(String localeStr) {
    if (localeStr == 'system') return null;
    
    // Check for script code (e.g. zh_Hant)
    if (localeStr.contains('_')) {
      final parts = localeStr.split('_');
      // Special handling for Traditional Chinese script code which might be stored as zh_Hant
      if (parts.length == 2 && parts[1] == 'Hant') {
         return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      }
      return Locale(parts[0], parts[1]);
    }
    
    return Locale(localeStr);
  }

  Future<void> setLocale(String localeStr) async {
    await _prefs.setLocale(localeStr);
    state = _parseLocale(localeStr);
  }
  
  // Helper to get play text for UI
  String getLocaleName(String code) {
    switch (code) {
      case 'system': return 'Follow System'; // Will be localized in UI
      case 'zh': return '简体中文';
      case 'zh_Hant': return '繁體中文';
      case 'en': return 'English';
      default: return code;
    }
  }
}

