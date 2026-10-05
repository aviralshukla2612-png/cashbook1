import 'package:drift/drift.dart';

@DataClassName('TransactionEntity')
class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get type => text()(); // CASH_IN or CASH_OUT
  IntColumn get amountPaisa => integer()(); // Minor units (paise) stored as int
  TextColumn get partyName => text().nullable()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
