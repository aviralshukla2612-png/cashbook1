import '../database/daos/settings_dao.dart';

class SettingsKeys {
  static const String openingBalancePaisa = 'opening_balance_paisa';
  static const String currencySymbol = 'currency_symbol';
  static const String themeMode = 'theme_mode';
  static const String appLockEnabled = 'app_lock_enabled';
  static const String userPin = 'user_pin';
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String lastBackupDate = 'last_backup_date';
}

class SettingsRepository {
  final SettingsDao _settingsDao;

  SettingsRepository(this._settingsDao);

  Stream<int> watchOpeningBalance() {
    return _settingsDao.watchSetting(SettingsKeys.openingBalancePaisa).map((val) {
      if (val == null) return 0;
      return int.tryParse(val) ?? 0;
    });
  }

  Future<int> getOpeningBalance() async {
    final val = await _settingsDao.getSetting(SettingsKeys.openingBalancePaisa);
    if (val == null) return 0;
    return int.tryParse(val) ?? 0;
  }

  Future<void> setOpeningBalance(int paisa) async {
    await _settingsDao.setSetting(SettingsKeys.openingBalancePaisa, paisa.toString());
  }

  Future<String> getThemeMode() async {
    return (await _settingsDao.getSetting(SettingsKeys.themeMode)) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _settingsDao.setSetting(SettingsKeys.themeMode, mode);
  }

  Future<String> getCurrencySymbol() async {
    return (await _settingsDao.getSetting(SettingsKeys.currencySymbol)) ?? '₹';
  }

  Future<void> setCurrencySymbol(String symbol) async {
    await _settingsDao.setSetting(SettingsKeys.currencySymbol, symbol);
  }

  Future<bool> isAppLockEnabled() async {
    final val = await _settingsDao.getSetting(SettingsKeys.appLockEnabled);
    return val == 'true';
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _settingsDao.setSetting(SettingsKeys.appLockEnabled, enabled.toString());
  }

  Future<String?> getUserPin() async {
    return await _settingsDao.getSetting(SettingsKeys.userPin);
  }

  Future<void> setUserPin(String pin) async {
    await _settingsDao.setSetting(SettingsKeys.userPin, pin);
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _settingsDao.getSetting(SettingsKeys.biometricsEnabled);
    return val == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _settingsDao.setSetting(SettingsKeys.biometricsEnabled, enabled.toString());
  }

  Future<String?> getLastBackupDate() async {
    return await _settingsDao.getSetting(SettingsKeys.lastBackupDate);
  }

  Future<void> setLastBackupDate(String isoString) async {
    await _settingsDao.setSetting(SettingsKeys.lastBackupDate, isoString);
  }

  Future<String?> getSetting(String key) async {
    return await _settingsDao.getSetting(key);
  }

  Future<void> setSetting(String key, String value) async {
    await _settingsDao.setSetting(key, value);
  }
}
