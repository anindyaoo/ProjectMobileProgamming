import 'package:get/get.dart';
import 'package:personal_finance/model/category_model.dart';
import 'package:personal_finance/services/firestore_service.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';

class CategoryController extends GetxController {
  final FirestoreService _repository = FirestoreService();
  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    categories.bindStream(_repository.getCategories());
  }

  List<CategoryModel> get incomeCategories =>
      categories.where((c) => c.type == 'Pemasukan').toList();

  List<CategoryModel> get expenseCategories =>
      categories.where((c) => c.type == 'Pengeluaran').toList();

  Future<void> addCategory(String name, String type) async {
    try {
      await _repository.addCategory(name, type);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Kategori berhasil ditambahkan',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menambahkan kategori',
      );
    }
  }

  Future<void> updateCategory(String id, String name, String type) async {
    try {
      await _repository.updateCategory(id, name, type);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Kategori berhasil diperbarui',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal memperbarui kategori',
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Kategori berhasil dihapus',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menghapus kategori',
      );
    }
  }
}
