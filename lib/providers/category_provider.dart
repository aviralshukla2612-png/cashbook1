import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import 'database_provider.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});

final categoryNotifierProvider = Provider<CategoryNotifier>((ref) {
  return CategoryNotifier(ref.watch(categoryRepositoryProvider));
});

class CategoryNotifier {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository);

  Future<void> addCategory({
    required String id,
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
  }) async {
    await _repository.addCategory(
      id: id,
      name: name,
      type: type,
      iconName: iconName,
      colorHex: colorHex,
    );
  }

  Future<bool> deleteCategory(String id) async {
    return await _repository.deleteCategory(id);
  }
}
