import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import '../model/transaction_model.dart';
import '../model/category_model.dart';
import '../services/firestore_service.dart';
import 'package:printing/printing.dart';
import '../utils/pdf_generator.dart';

class TransactionController extends GetxController {
  // Dependency Injection (Polymorphism support via abstraction if needed)
  final FirestoreService _repository = FirestoreService();

  // Encapsulation: Observable state variables
  var transactions = <TransactionModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'Semua'.obs; // 'Semua', 'Hari Ini', 'Bulan Ini'

  // Report Filter State
  var selectedReportMonth = DateTime.now().month.obs;
  var selectedReportYear = DateTime.now().year.obs;

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

  // Report Getters
  List<TransactionModel> get reportTransactions {
    final filtered = transactions.where((t) {
      return t.date.year == selectedReportYear.value &&
          t.date.month == selectedReportMonth.value;
    }).toList();
    // Sort by date descending
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  double get reportIncome {
    return reportTransactions
        .where((t) => t.type == 'Pemasukan')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get reportExpense {
    return reportTransactions
        .where((t) => t.type == 'Pengeluaran')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get reportBalance => reportIncome - reportExpense;

  Future<void> downloadReportPdf() async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      final bytes = await PdfGenerator.generatePdf(
        month: selectedReportMonth.value,
        year: selectedReportYear.value,
        totalIncome: reportIncome,
        totalExpense: reportExpense,
        balance: reportBalance,
        transactions: reportTransactions,
      );

      final monthName = DateFormat(
        'MMMM',
        'id_ID',
      ).format(DateTime(selectedReportYear.value, selectedReportMonth.value));
      final fileName =
          'Laporan Keuangan Bulan $monthName ${selectedReportYear.value} MyFinance.pdf';

      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal mengunduh PDF: $e',
      );
    } finally {
      isLoading.value = false;
    }
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

  void updateReportMonth(int month) {
    selectedReportMonth.value = month;
  }

  void updateReportYear(int year) {
    selectedReportYear.value = year;
  }

  Future<void> addCategory(String categoryName, String type) async {
    try {
      await _repository.addCategory(categoryName, type);
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

  List<String> getCategoriesByType(String type) {
    return categories.where((c) => c.type == type).map((c) => c.name).toList();
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

  Future<void> deleteAllTransactions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _repository.deleteAllTransactions(uid);
        CustomSnackbar.showSuccess(
          title: 'Sukses',
          message: 'Semua data transaksi berhasil dihapus',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menghapus data transaksi: $e',
      );
    }
  }
}
