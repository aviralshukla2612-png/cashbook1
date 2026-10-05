import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  Stream<String?> watchSetting(String key) {
    return (select(settingsTable)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(settingsTable)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settingsTable).insert(
      SettingsTableCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> deleteSetting(String key) {
    return (delete(settingsTable)..where((s) => s.key.equals(key))).go();
  }
}
