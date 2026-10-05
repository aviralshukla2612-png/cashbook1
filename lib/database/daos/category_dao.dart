import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Stream<List<CategoryEntity>> watchAllCategories() {
    return (select(categoriesTable)..orderBy([(c) => OrderingTerm(expression: c.name)])).watch();
  }

  Future<List<CategoryEntity>> getAllCategories() {
    return (select(categoriesTable)..orderBy([(c) => OrderingTerm(expression: c.name)])).get();
  }

  Future<CategoryEntity?> getCategoryById(String id) {
    return (select(categoriesTable)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCategory(CategoriesTableCompanion entity) {
    return into(categoriesTable).insert(entity, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateCategory(CategoriesTableCompanion entity) {
    return update(categoriesTable).replace(entity);
  }

  Future<int> deleteCategory(String id) {
    return (delete(categoriesTable)..where((c) => c.id.equals(id))).go();
  }
}
