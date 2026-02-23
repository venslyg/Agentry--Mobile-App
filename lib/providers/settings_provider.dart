import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier()
      : super(SettingsModel(languageCode: 'en', darkMode: false)) {
    _load();
  }

  static const _boxName = 'settings';

  Box<SettingsModel> get _box => Hive.box<SettingsModel>(_boxName);

  void _load() {
    final saved = _box.get('prefs');
    if (saved != null) {
      // Safety: ensure currencyCode is initialized if loading old data
      // We check for length to be safe against nulls and empty strings
      try {
        if (saved.currencyCode == null || saved.currencyCode!.isEmpty) {
          saved.currencyCode = 'LKR';
        }
      } catch (_) {
        saved.currencyCode = 'LKR';
      }
      state = saved;
    }
  }

  Future<void> setLanguage(String code) async {
    state = SettingsModel(
      languageCode: code,
      darkMode: state.darkMode,
      currencyCode: state.currencyCode,
    );
    await _box.put('prefs', state);
  }

  Future<void> setDarkMode(bool dark) async {
    state = SettingsModel(
      languageCode: state.languageCode,
      darkMode: dark,
      currencyCode: state.currencyCode,
    );
    await _box.put('prefs', state);
  }

  Future<void> setCurrency(String code) async {
    state = SettingsModel(
      languageCode: state.languageCode,
      darkMode: state.darkMode,
      currencyCode: code,
    );
    await _box.put('prefs', state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

// Convenient computed locale provider
final localeProvider = Provider<Locale>((ref) {
  final code = ref.watch(settingsProvider).languageCode;
  return Locale(code);
});

final currencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(settingsProvider).currencyCode;
  switch (code) {
    case 'LKR':
      return 'Rs. ';
    case 'AED':
      return 'د.إ ';
    case 'SAR':
      return 'ر.س ';
    case 'KWD':
      return 'د.ك ';
    case 'QAR':
      return 'ر.ق ';
    case 'OMR':
      return 'ر.ع. ';
    case 'JOD':
      return 'د.أ ';
    default:
      return '$code ';
  }
});
