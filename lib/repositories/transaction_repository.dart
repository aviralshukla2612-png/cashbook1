import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/category_dao.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../core/enums/transaction_type.dart';

class TransactionRepository {
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;

  TransactionRepository(this._transactionDao, this._categoryDao);

  Stream<List<TransactionModel>> watchTransactions({String? accountId}) {
    return _transactionDao.watchAllTransactions(accountId: accountId).asyncMap((entities) async {
      final categories = await _categoryDao.getAllCategories();
      final categoryMap = {for (var c in categories) c.id: c};
      return entities.map((e) => _toModel(e, categoryMap[e.categoryId])).toList();
    });
  }

  Future<List<TransactionModel>> getAllTransactions({String? accountId}) async {
    final entities = await _transactionDao.getAllTransactions(accountId: accountId);
    final categories = await _categoryDao.getAllCategories();
    final categoryMap = {for (var c in categories) c.id: c};
    return entities.map((e) => _toModel(e, categoryMap[e.categoryId])).toList();
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    final entity = await _transactionDao.getTransactionById(id);
    if (entity == null) return null;
    final catEntity = await _categoryDao.getCategoryById(entity.categoryId);
    return _toModel(entity, catEntity);
  }

  Future<void> addTransaction({
    required String id,
    String? accountId,
    required TransactionType type,
    required int amountPaisa,
    String? partyName,
    required String categoryId,
    String? description,
    required DateTime transactionDate,
  }) async {
    final now = DateTime.now();
    final companion = TransactionsTableCompanion.insert(
      id: id,
      accountId: Value(accountId),
      type: type.dbValue,
      amountPaisa: amountPaisa,
      partyName: Value(partyName),
      categoryId: categoryId,
      description: Value(description),
      transactionDate: transactionDate,
      createdAt: now,
      updatedAt: now,
    );
    await _transactionDao.insertTransaction(companion);
  }

  Future<void> updateTransaction({
    required String id,
    String? accountId,
    required TransactionType type,
    required int amountPaisa,
    String? partyName,
    required String categoryId,
    String? description,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) async {
    final companion = TransactionsTableCompanion.insert(
      id: id,
      accountId: Value(accountId),
      type: type.dbValue,
      amountPaisa: amountPaisa,
      partyName: Value(partyName),
      categoryId: categoryId,
      description: Value(description),
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
    await _transactionDao.updateTransaction(companion);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionDao.deleteTransaction(id);
  }

  TransactionModel _toModel(TransactionEntity entity, CategoryEntity? catEntity) {
    return TransactionModel(
      id: entity.id,
      type: TransactionType.fromDbValue(entity.type),
      amountPaisa: entity.amountPaisa,
      partyName: entity.partyName,
      categoryId: entity.categoryId,
      categoryName: catEntity?.name ?? 'Uncategorized',
      categoryColor: catEntity != null ? CategoryModel(
        id: catEntity.id,
        name: catEntity.name,
        type: catEntity.type,
        iconName: catEntity.iconName,
        colorHex: catEntity.colorHex,
        isDefault: catEntity.isDefault,
        createdAt: catEntity.createdAt,
      ).color : null,
      categoryIcon: catEntity != null ? CategoryModel.getIconByName(catEntity.iconName) : null,
      description: entity.description,
      transactionDate: entity.transactionDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
