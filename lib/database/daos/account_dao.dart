import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/accounts_table.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [AccountsTable])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(AppDatabase db) : super(db);

  Stream<List<AccountEntity>> watchAllAccounts() {
    return (select(accountsTable)
          ..orderBy([
            (a) => OrderingTerm(expression: a.isDefault, mode: OrderingMode.desc),
            (a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<AccountEntity>> getAllAccounts() {
    return (select(accountsTable)
          ..orderBy([
            (a) => OrderingTerm(expression: a.isDefault, mode: OrderingMode.desc),
            (a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<AccountEntity?> getAccountById(String id) {
    return (select(accountsTable)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertAccount(AccountsTableCompanion entity) {
    return into(accountsTable).insert(entity);
  }

  Future<bool> updateAccount(AccountsTableCompanion entity) {
    return update(accountsTable).replace(entity);
  }

  Future<int> deleteAccount(String id) {
    return (delete(accountsTable)..where((a) => a.id.equals(id))).go();
  }
}
