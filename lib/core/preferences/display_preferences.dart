import 'package:flutter/material.dart';

import 'package:stashly/core/storage/key_value_store.dart';

/// Interface languages the app ships. `null` in [DisplayPreferences.language]
/// means "follow the device".
enum AppLanguage {
  english('en'),
  arabic('ar');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage? fromCode(Object? code) =>
      AppLanguage.values.where((l) => l.code == code).firstOrNull;
}

/// The user's theme and language choices, kept on the device.
///
/// Dark is Stashly's primary brand experience, so it is the default until
/// the user picks Light or "System".
class DisplayPreferences extends ChangeNotifier {
  DisplayPreferences(this._store);

  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';

  final KeyValueStore _store;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  AppLanguage? _language;

  /// The chosen interface language; `null` follows the device.
  AppLanguage? get language => _language;

  /// Locale override for MaterialApp; `null` lets the device decide.
  Locale? get locale => _language?.locale;

  Future<void> load() async {
    final theme = await _store.read(_themeKey);
    _themeMode =
        ThemeMode.values.where((m) => m.name == theme).firstOrNull ??
        ThemeMode.dark;
    _language = AppLanguage.fromCode(await _store.read(_languageKey));
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store.write(_themeKey, mode.name);
  }

  /// `null` follows the device language.
  Future<void> setLanguage(AppLanguage? language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    await _store.write(_languageKey, language?.code);
  }
}
