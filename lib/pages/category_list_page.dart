import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance/controllers/category_controller.dart';
import 'package:personal_finance/model/category_model.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF355C9A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pemasukan'),
              Tab(text: 'Pengeluaran'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(controller, 'Pemasukan'),
            _buildCategoryList(controller, 'Pengeluaran'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context, controller),
          backgroundColor: const Color(0xFF355C9A),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryList(CategoryController controller, String type) {
    return Obx(() {
      final categories = type == 'Pemasukan'
          ? controller.incomeCategories
          : controller.expenseCategories;

      if (categories.isEmpty) {
        return Center(
          child: Text(
            'Belum ada kategori $type',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF355C9A).withValues(alpha: 0.1),
                child: Icon(
                  type == 'Pemasukan'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: const Color(0xFF355C9A),
                ),
              ),
              title: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCategoryDialog(
                      context,
                      controller,
                      category: category,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _showDeleteConfirmDialog(context, controller, category),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showCategoryDialog(
    BuildContext context,
    CategoryController controller, {
    CategoryModel? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final typeController = RxString(category?.type ?? 'Pengeluaran');
    final isEditing = category != null;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add_circle,
                      color: const Color(0xFF355C9A),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF355C9A)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isEditing) ...[
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: typeController.value,
                      decoration: InputDecoration(
                        labelText: 'Tipe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pemasukan',
                          child: Text('Pemasukan'),
                        ),
                        DropdownMenuItem(
                          value: 'Pengeluaran',
                          child: Text('Pengeluaran'),
                        ),
                      ],
                      onChanged: (value) => typeController.value = value!,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (isEditing) const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          if (isEditing) {
                            controller.updateCategory(
                              category.id,
                              nameController.text,
                              category.type,
                            );
                          } else {
                            controller.addCategory(
                              nameController.text,
                              typeController.value,
                            );
                          }
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF355C9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CategoryController controller,
    CategoryModel category,
  ) {
    Get.defaultDialog(
      title: 'Hapus Kategori',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
      middleText:
          'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
      middleTextStyle: const TextStyle(color: Color(0xFF666666)),
      radius: 16,
      contentPadding: const EdgeInsets.all(20),
      confirm: ElevatedButton(
        onPressed: () {
          controller.deleteCategory(category.id);
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        child: const Text('Hapus', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
