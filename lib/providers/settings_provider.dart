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
    if (saved != null) state = saved;
  }

  Future<void> setLanguage(String code) async {
    state = SettingsModel(languageCode: code, darkMode: state.darkMode);
    await _box.put('prefs', state);
  }

  Future<void> setDarkMode(bool dark) async {
    state = SettingsModel(languageCode: state.languageCode, darkMode: dark);
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
