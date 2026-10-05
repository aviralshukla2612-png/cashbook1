import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryDao _categoryDao;
  final TransactionDao _transactionDao;

  CategoryRepository(this._categoryDao, this._transactionDao);

  Stream<List<CategoryModel>> watchCategories() {
    return _categoryDao.watchAllCategories().map(
          (entities) => entities.map(_toModel).toList(),
        );
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final entities = await _categoryDao.getAllCategories();
    return entities.map(_toModel).toList();
  }

  Future<void> addCategory({
    required String id,
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
  }) async {
    final companion = CategoriesTableCompanion.insert(
      id: id,
      name: name,
      type: type,
      iconName: iconName,
      colorHex: colorHex,
      isDefault: const Value(false),
      createdAt: DateTime.now(),
    );
    await _categoryDao.insertCategory(companion);
  }

  Future<bool> deleteCategory(String id) async {
    // Check if category is used in any transactions
    final transactions = await _transactionDao.getAllTransactions();
    final isUsed = transactions.any((t) => t.categoryId == id);
    if (isUsed) {
      return false; // Prevent deletion of used category
    }
    await _categoryDao.deleteCategory(id);
    return true;
  }

  CategoryModel _toModel(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      iconName: entity.iconName,
      colorHex: entity.colorHex,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }
}
