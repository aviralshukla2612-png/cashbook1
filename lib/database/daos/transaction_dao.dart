import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  Stream<List<TransactionEntity>> watchAllTransactions({String? accountId}) {
    final query = select(transactionsTable);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId) | t.accountId.isNull());
    }
    return (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<TransactionEntity>> getAllTransactions({String? accountId}) {
    final query = select(transactionsTable);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId) | t.accountId.isNull());
    }
    return (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<TransactionEntity?> getTransactionById(String id) {
    return (select(transactionsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTransaction(TransactionsTableCompanion entity) {
    return into(transactionsTable).insert(entity);
  }

  Future<bool> updateTransaction(TransactionsTableCompanion entity) {
    return update(transactionsTable).replace(entity);
  }

  Future<int> deleteTransaction(String id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteTransactionsByAccountId(String accountId) {
    return (delete(transactionsTable)..where((t) => t.accountId.equals(accountId))).go();
  }

  Future<int> deleteAllTransactions() {
    return delete(transactionsTable).go();
  }
}
