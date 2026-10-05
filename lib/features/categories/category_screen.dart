import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../shared/widgets/custom_card.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, String defaultType) {
    final nameController = TextEditingController();
    String selectedType = defaultType;
    String selectedIcon = 'category';
    Color selectedColor = AppColors.primary;

    final availableIcons = [
      'shopping_bag',
      'payments',
      'account_balance',
      'show_chart',
      'add_card',
      'shopping_cart',
      'badge',
      'directions_bus',
      'restaurant',
      'bolt',
      'home',
      'work',
      'receipt_long',
      'phone_android',
      'local_hospital',
      'school',
      'flight',
      'build',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Custom Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'e.g. Fuel, Marketing',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Cash In'),
                            selected: selectedType == 'CASH_IN',
                            onSelected: (sel) {
                              if (sel) setDialogState(() => selectedType = 'CASH_IN');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Cash Out'),
                            selected: selectedType == 'CASH_OUT',
                            onSelected: (sel) {
                              if (sel) setDialogState(() => selectedType = 'CASH_OUT');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Icon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableIcons.map((iconName) {
                        final iconData = CategoryModel.getIconByName(iconName);
                        final isSelected = selectedIcon == iconName;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedIcon = iconName),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              size: 20,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final notifier = ref.read(categoryNotifierProvider);
                      await notifier.addCategory(
                        id: 'cat_${const Uuid().v4()}',
                        name: name,
                        type: selectedType,
                        iconName: selectedIcon,
                        colorHex: '0xFF${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                      );
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Category'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final notifier = ref.read(categoryNotifierProvider);
    final success = await notifier.deleteCategory(category.id);

    if (!mounted) return;

    if (!success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cannot Delete Category'),
          content: Text(
            'The category "${category.name}" is already assigned to existing transactions. Modify or delete those transactions before removing this category.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${category.name}" deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cash In Categories'),
            Tab(text: 'Cash Out Categories'),
          ],
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final cashInCats = categories.where((c) => c.type == 'CASH_IN' || c.type == 'BOTH').toList();
          final cashOutCats = categories.where((c) => c.type == 'CASH_OUT' || c.type == 'BOTH').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(cashInCats, 'CASH_IN'),
              _buildCategoryList(cashOutCats, 'CASH_OUT'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading categories: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = _tabController.index == 0 ? 'CASH_IN' : 'CASH_OUT';
          _showAddCategoryDialog(context, type);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories, String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.iconData, color: cat.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (cat.isDefault)
                        const Text(
                          'Default Category',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (!cat.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteCategory(cat),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
