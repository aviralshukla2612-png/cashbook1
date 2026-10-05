import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';

class BackupRestoreService {
  final AppDatabase _db;

  BackupRestoreService(this._db);

  /// Creates a backup JSON file containing all ledger data, user accounts, and metadata
  Future<File> createBackupFile() async {
    final transactions = await _db.select(_db.transactionsTable).get();
    final categories = await _db.select(_db.categoriesTable).get();
    final settings = await _db.select(_db.settingsTable).get();
    final accounts = await _db.select(_db.accountsTable).get();

    final backupData = {
      'version': '2.0',
      'appName': 'Daily Cashbook',
      'createdAt': DateTime.now().toIso8601String(),
      'accounts': accounts.map((a) => {
            'id': a.id,
            'name': a.name,
            'phone': a.phone,
            'email': a.email,
            'initialBalancePaisa': a.initialBalancePaisa,
            'notes': a.notes,
            'isDefault': a.isDefault,
            'createdAt': a.createdAt.toIso8601String(),
            'updatedAt': a.updatedAt.toIso8601String(),
          }).toList(),
      'transactions': transactions.map((t) => {
            'id': t.id,
            'accountId': t.accountId,
            'type': t.type,
            'amountPaisa': t.amountPaisa,
            'partyName': t.partyName,
            'categoryId': t.categoryId,
            'description': t.description,
            'transactionDate': t.transactionDate.toIso8601String(),
            'createdAt': t.createdAt.toIso8601String(),
            'updatedAt': t.updatedAt.toIso8601String(),
          }).toList(),
      'categories': categories.map((c) => {
            'id': c.id,
            'name': c.name,
            'type': c.type,
            'iconName': c.iconName,
            'colorHex': c.colorHex,
            'isDefault': c.isDefault,
            'createdAt': c.createdAt.toIso8601String(),
          }).toList(),
      'settings': settings.map((s) => {
            'key': s.key,
            'value': s.value,
          }).toList(),
    };

    final String jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

    final dir = await getApplicationDocumentsDirectory();
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'daily_cashbook_backup_$dateStr.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonString);

    final settingsRepo = SettingsRepository(_db.settingsDao);
    await settingsRepo.setLastBackupDate(DateTime.now().toIso8601String());

    return file;
  }

  Future<void> shareBackupFile() async {
    final file = await createBackupFile();
    await Share.shareXFiles([XFile(file.path)], text: 'Daily Cashbook Backup Data');
  }

  /// Restores database state from a backup file path.
  Future<bool> restoreFromBackupPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FormatException('Backup file not found.');
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (data['appName'] != 'Daily Cashbook' ||
        !data.containsKey('transactions') ||
        !data.containsKey('categories')) {
      throw const FormatException('Invalid or corrupted Daily Cashbook backup file.');
    }

    final List<dynamic> transactionsJson = data['transactions'];
    final List<dynamic> categoriesJson = data['categories'];
    final List<dynamic> accountsJson = data['accounts'] ?? [];
    final List<dynamic> settingsJson = data['settings'] ?? [];

    await _db.transaction(() async {
      await _db.delete(_db.transactionsTable).go();
      await _db.delete(_db.categoriesTable).go();
      await _db.delete(_db.accountsTable).go();
      await _db.delete(_db.settingsTable).go();

      for (final item in accountsJson) {
        await _db.into(_db.accountsTable).insert(
              AccountsTableCompanion.insert(
                id: item['id'],
                name: item['name'],
                phone: Value(item['phone']),
                email: Value(item['email']),
                initialBalancePaisa: Value(item['initialBalancePaisa'] ?? 0),
                notes: Value(item['notes']),
                isDefault: Value(item['isDefault'] ?? false),
                createdAt: DateTime.parse(item['createdAt']),
                updatedAt: DateTime.parse(item['updatedAt']),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final item in categoriesJson) {
        await _db.into(_db.categoriesTable).insert(
              CategoriesTableCompanion.insert(
                id: item['id'],
                name: item['name'],
                type: item['type'],
                iconName: item['iconName'],
                colorHex: item['colorHex'],
                isDefault: Value(item['isDefault'] ?? false),
                createdAt: DateTime.parse(item['createdAt']),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final item in transactionsJson) {
        await _db.into(_db.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                id: item['id'],
                accountId: Value(item['accountId']),
                type: item['type'],
                amountPaisa: item['amountPaisa'],
                partyName: Value(item['partyName']),
                categoryId: item['categoryId'],
                description: Value(item['description']),
                transactionDate: DateTime.parse(item['transactionDate']),
                createdAt: DateTime.parse(item['createdAt']),
                updatedAt: DateTime.parse(item['updatedAt']),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final item in settingsJson) {
        await _db.into(_db.settingsTable).insert(
              SettingsTableCompanion.insert(
                key: item['key'],
                value: item['value'],
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });

    return true;
  }

  Future<bool> pickAndRestoreBackup() async {
    final result = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'db'],
    );

    if (result != null && result.isNotEmpty && result.first.path != null) {
      return await restoreFromBackupPath(result.first.path!);
    }
    return false;
  }
}
