import 'package:flutter/material.dart'; // ADD THIS IMPORT
import 'package:flutter/foundation.dart'; // AND ADD THIS IMPORT
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  SettingsModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometricStored = await _storage.read(key: 'biometric_enabled');
    _isBiometricEnabled = biometricStored == 'true';

    final themeStored = await _storage.read(key: 'theme_mode');
    if (themeStored == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStored == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(key: 'biometric_enabled', value: value.toString());
    _isBiometricEnabled = value;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String themeString;
    if (mode == ThemeMode.light) {
      themeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeString = 'dark';
    } else {
      themeString = 'system';
    }
    await _storage.write(key: 'theme_mode', value: themeString);
    _themeMode = mode;
    notifyListeners();
  }
}