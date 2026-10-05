import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/settings_table.dart';
import 'tables/accounts_table.dart';
import 'daos/transaction_dao.dart';
import 'daos/category_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/account_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [TransactionsTable, CategoriesTable, SettingsTable, AccountsTable],
  daos: [TransactionDao, CategoryDao, SettingsDao, AccountDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'daily_cashbook',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
        await _seedDefaultAccount();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(accountsTable);
          await m.addColumn(transactionsTable, transactionsTable.accountId);
          await _seedDefaultAccount();
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          final count = await (select(categoriesTable).get());
          if (count.isEmpty) {
            await _seedDefaultCategories();
          }
          final accCount = await (select(accountsTable).get());
          if (accCount.isEmpty) {
            await _seedDefaultAccount();
          }
        } else {
          final accCount = await (select(accountsTable).get());
          if (accCount.isEmpty) {
            await _seedDefaultAccount();
          }
        }
      },
    );
  }

  Future<void> _seedDefaultAccount() async {
    final now = DateTime.now();
    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_default',
        name: 'Aviral',
        isDefault: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> _seedDefaultCategories() async {
    final now = DateTime.now();
    final defaultCategories = [
      // CASH IN
      CategoriesTableCompanion.insert(
        id: 'cat_sales',
        name: 'Sales',
        type: 'CASH_IN',
        iconName: 'shopping_bag',
        colorHex: '0xFF10B981',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_customer_payment',
        name: 'Customer Payment',
        type: 'CASH_IN',
        iconName: 'payments',
        colorHex: '0xFF059669',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_loan',
        name: 'Loan',
        type: 'CASH_IN',
        iconName: 'account_balance',
        colorHex: '0xFF0D9488',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_investment',
        name: 'Investment',
        type: 'CASH_IN',
        iconName: 'show_chart',
        colorHex: '0xFF0284C7',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_other_income',
        name: 'Other Income',
        type: 'CASH_IN',
        iconName: 'add_card',
        colorHex: '0xFF2563EB',
        isDefault: const Value(true),
        createdAt: now,
      ),

      // CASH OUT
      CategoriesTableCompanion.insert(
        id: 'cat_purchase',
        name: 'Purchase',
        type: 'CASH_OUT',
        iconName: 'shopping_cart',
        colorHex: '0xFFEF4444',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_salary',
        name: 'Salary',
        type: 'CASH_OUT',
        iconName: 'badge',
        colorHex: '0xFFF97316',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_transport',
        name: 'Transport',
        type: 'CASH_OUT',
        iconName: 'directions_bus',
        colorHex: '0xFFF59E0B',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_food',
        name: 'Food',
        type: 'CASH_OUT',
        iconName: 'restaurant',
        colorHex: '0xFFEA580C',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_electricity',
        name: 'Electricity',
        type: 'CASH_OUT',
        iconName: 'bolt',
        colorHex: '0xFFEAB308',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_rent',
        name: 'Rent',
        type: 'CASH_OUT',
        iconName: 'home',
        colorHex: '0xFF9333EA',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_office_expense',
        name: 'Office Expense',
        type: 'CASH_OUT',
        iconName: 'work',
        colorHex: '0xFF4F46E5',
        isDefault: const Value(true),
        createdAt: now,
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_other_expense',
        name: 'Other Expense',
        type: 'CASH_OUT',
        iconName: 'receipt_long',
        colorHex: '0xFFEC4899',
        isDefault: const Value(true),
        createdAt: now,
      ),
    ];

    await batch((b) {
      b.insertAll(categoriesTable, defaultCategories, mode: InsertMode.insertOrIgnore);
    });
  }
}
