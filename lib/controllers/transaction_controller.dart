import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import '../model/transaction_model.dart';
import '../services/firestore_service.dart';

class TransactionController extends GetxController {
  // Dependency Injection (Polymorphism support via abstraction if needed)
  final FirestoreService _repository = FirestoreService();

  // Encapsulation: Observable state variables
  var transactions = <TransactionModel>[].obs;
  var categories = <String>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'Semua'.obs; // 'Semua', 'Hari Ini', 'Bulan Ini'

  // Computed properties (Getters)
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    if (selectedFilter.value == 'Hari Ini') {
      return transactions.where((t) {
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      }).toList();
    } else if (selectedFilter.value == 'Bulan Ini') {
      return transactions.where((t) {
        return t.date.year == now.year && t.date.month == now.month;
      }).toList();
    }
    return transactions;
  }

  // Ringkasan Bulan Ini (Computed)
  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) {
          final isSameMonth =
              t.date.year == now.year && t.date.month == now.month;
          return t.type == 'Pemasukan' && isSameMonth;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenseThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) {
          final isSameMonth =
              t.date.year == now.year && t.date.month == now.month;
          return t.type == 'Pengeluaran' && isSameMonth;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentBalance {
    final income = transactions
        .where((t) => t.type == 'Pemasukan')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == 'Pengeluaran')
        .fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes to bind streams
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        transactions.bindStream(_repository.getTransactions(user.uid));
        categories.bindStream(_repository.getCategories());
      } else {
        transactions.clear();
        categories.clear();
      }
    });
    isLoading.value = false;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> addCategory(String categoryName) async {
    try {
      await _repository.addCategory(categoryName);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Kategori berhasil ditambahkan',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menambahkan kategori: $e',
      );
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Transaksi berhasil ditambahkan',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menambahkan transaksi: $e',
      );
    }
  }

  Future<void> updateTransaction(
    String id,
    TransactionModel transaction,
  ) async {
    try {
      await _repository.updateTransaction(id, transaction);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Transaksi berhasil diperbarui',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal memperbarui transaksi: $e',
      );
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Transaksi berhasil dihapus',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menghapus transaksi: $e',
      );
    }
  }
}
