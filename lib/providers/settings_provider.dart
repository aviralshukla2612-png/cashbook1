import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/settings_repository.dart';
import '../core/enums/app_theme_mode.dart';
import 'database_provider.dart';

import '../core/utils/currency_formatter.dart';

final openingBalanceStreamProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchOpeningBalance();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late SettingsRepository _repository;

  @override
  ThemeMode build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final modeStr = await _repository.getThemeMode();
    switch (modeStr) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    switch (mode) {
      case AppThemeMode.light:
        state = ThemeMode.light;
        await _repository.setThemeMode('light');
        break;
      case AppThemeMode.dark:
        state = ThemeMode.dark;
        await _repository.setThemeMode('dark');
        break;
      case AppThemeMode.system:
        state = ThemeMode.system;
        await _repository.setThemeMode('system');
        break;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class CurrencySymbolNotifier extends Notifier<String> {
  late SettingsRepository _repository;

  @override
  String build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadCurrency();
    return CurrencyFormatter.defaultSymbol;
  }

  Future<void> _loadCurrency() async {
    final symbol = await _repository.getCurrencySymbol();
    state = symbol;
    CurrencyFormatter.defaultSymbol = symbol;
  }

  Future<void> setCurrencySymbol(String symbol) async {
    state = symbol;
    CurrencyFormatter.defaultSymbol = symbol;
    await _repository.setCurrencySymbol(symbol);
  }
}

final currencySymbolProvider = NotifierProvider<CurrencySymbolNotifier, String>(CurrencySymbolNotifier.new);

class SecuritySettingsState {
  final bool isAppLockEnabled;
  final bool isBiometricsEnabled;
  final bool hasPinSet;

  const SecuritySettingsState({
    this.isAppLockEnabled = false,
    this.isBiometricsEnabled = false,
    this.hasPinSet = false,
  });

  SecuritySettingsState copyWith({
    bool? isAppLockEnabled,
    bool? isBiometricsEnabled,
    bool? hasPinSet,
  }) {
    return SecuritySettingsState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      hasPinSet: hasPinSet ?? this.hasPinSet,
    );
  }
}

class SecuritySettingsNotifier extends Notifier<SecuritySettingsState> {
  late SettingsRepository _repository;

  @override
  SecuritySettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    loadSettings();
    return const SecuritySettingsState();
  }

  Future<void> loadSettings() async {
    final isLock = await _repository.isAppLockEnabled();
    final isBio = await _repository.isBiometricsEnabled();
    final pin = await _repository.getUserPin();

    state = SecuritySettingsState(
      isAppLockEnabled: isLock,
      isBiometricsEnabled: isBio,
      hasPinSet: pin != null && pin.isNotEmpty,
    );
  }

  Future<void> toggleAppLock(bool enabled) async {
    await _repository.setAppLockEnabled(enabled);
    state = state.copyWith(isAppLockEnabled: enabled);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    await _repository.setBiometricsEnabled(enabled);
    state = state.copyWith(isBiometricsEnabled: enabled);
  }

  Future<void> setPin(String pin) async {
    await _repository.setUserPin(pin);
    state = state.copyWith(hasPinSet: true);
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await _repository.getUserPin();
    return savedPin == pin;
  }
}

final securitySettingsProvider =
    NotifierProvider<SecuritySettingsNotifier, SecuritySettingsState>(SecuritySettingsNotifier.new);
