import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../models/account_model.dart';

class AccountRepository {
  final AccountDao _accountDao;
  final TransactionDao _transactionDao;

  AccountRepository(this._accountDao, this._transactionDao);

  Stream<List<AccountModel>> watchAccounts() {
    return _accountDao.watchAllAccounts().map((entities) {
      return entities.map(_toModel).toList();
    });
  }

  Future<List<AccountModel>> getAllAccounts() async {
    final entities = await _accountDao.getAllAccounts();
    return entities.map(_toModel).toList();
  }

  Future<AccountModel?> getAccountById(String id) async {
    final entity = await _accountDao.getAccountById(id);
    if (entity == null) return null;
    return _toModel(entity);
  }

  Future<void> addAccount({
    required String id,
    required String name,
    String? phone,
    String? email,
    int initialBalancePaisa = 0,
    String? notes,
    bool isDefault = false,
  }) async {
    final now = DateTime.now();
    final companion = AccountsTableCompanion.insert(
      id: id,
      name: name,
      phone: Value(phone),
      email: Value(email),
      initialBalancePaisa: Value(initialBalancePaisa),
      notes: Value(notes),
      isDefault: Value(isDefault),
      createdAt: now,
      updatedAt: now,
    );
    await _accountDao.insertAccount(companion);
  }

  Future<void> updateAccount({
    required String id,
    required String name,
    String? phone,
    String? email,
    int initialBalancePaisa = 0,
    String? notes,
    required bool isDefault,
    required DateTime createdAt,
  }) async {
    final companion = AccountsTableCompanion.insert(
      id: id,
      name: name,
      phone: Value(phone),
      email: Value(email),
      initialBalancePaisa: Value(initialBalancePaisa),
      notes: Value(notes),
      isDefault: Value(isDefault),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
    await _accountDao.updateAccount(companion);
  }

  Future<void> deleteAccount(String id) async {
    // Delete associated transactions first
    await _transactionDao.deleteTransactionsByAccountId(id);
    // Delete account record
    await _accountDao.deleteAccount(id);
  }

  AccountModel _toModel(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      initialBalancePaisa: entity.initialBalancePaisa,
      notes: entity.notes,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
