import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import '../model/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../controllers/transaction_controller.dart';
import 'package:personal_finance/pages/category_list_page.dart';
import 'package:personal_finance/pages/main_page.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TransactionController transactionController =
      Get.find<TransactionController>();

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final newCategoryController = TextEditingController();

  String? selectedCategory;
  String selectedType = 'Pengeluaran';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      amountController.text = CurrencyInputFormatter.formatAmount(tx.amount);
      noteController.text = tx.note;
      selectedCategory = tx.category;
      selectedType = tx.type;
      selectedDate = tx.date;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _showAddCategoryDialog() {
    newCategoryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Tambah Kategori ($selectedType)'),
          content: TextField(
            controller: newCategoryController,
            decoration: const InputDecoration(
              hintText: 'Nama Kategori Baru',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => const CategoryListPage());
              },
              icon: const Icon(Icons.category, color: Color(0xFF355C9A)),
              tooltip: 'Kelola Kategori',
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final newCategory = newCategoryController.text.trim();
                    if (newCategory.isNotEmpty) {
                      transactionController.addCategory(
                        newCategory,
                        selectedType,
                      );
                      setState(() {
                        selectedCategory = newCategory;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355C9A),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    final amount = CurrencyInputFormatter.parseFormattedValue(
      amountController.text,
    );

    final availableCategories = transactionController.getCategoriesByType(
      selectedType,
    );

    if (amount <= 0 ||
        selectedCategory == null ||
        !availableCategories.contains(selectedCategory)) {
      CustomSnackbar.showWarning(
        title: 'Perhatian',
        message: 'Mohon lengkapi data transaksi dengan benar',
      );
      return;
    }

    final note = noteController.text;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackbar.showError(title: 'Error', message: 'Anda belum login');
      return;
    }

    final newTransaction = TransactionModel(
      userId: user.uid,
      type: selectedType,
      amount: amount,
      category: selectedCategory!,
      date: selectedDate,
      note: note,
    );

    if (widget.transactionToEdit != null) {
      Get.defaultDialog(
        title: 'Konfirmasi Update',
        middleText:
            'Apakah Anda yakin ingin menyimpan perubahan transaksi ini?',
        titlePadding: const EdgeInsets.only(top: 20),
        contentPadding: const EdgeInsets.all(20),
        radius: 16,
        confirm: ElevatedButton(
          onPressed: () async {
            Get.back(); // Close dialog
            await transactionController.updateTransaction(
              widget.transactionToEdit!.id!,
              newTransaction,
            );
            Get.offAll(() => const MainPage(initialIndex: 1));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF355C9A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'Ya, Simpan',
            style: TextStyle(color: Colors.white),
          ),
        ),
        cancel: OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Batal', style: TextStyle(color: Colors.black87)),
        ),
      );
    } else {
      await transactionController.addTransaction(newTransaction);
      Get.offAll(() => const MainPage(initialIndex: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit != null
              ? 'Edit Transaksi'
              : 'Tambah Transaksi',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF355C9A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipe', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Pengeluaran',
                      child: Text('Pengeluaran'),
                    ),
                    DropdownMenuItem(
                      value: 'Pemasukan',
                      child: Text('Pemasukan'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      selectedCategory = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nominal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                hintText: 'Rp',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() {
                  final categories = transactionController.getCategoriesByType(
                    selectedType,
                  );

                  String? currentValue = selectedCategory;
                  if (currentValue != null &&
                      !categories.contains(currentValue)) {
                    currentValue = null;
                  }

                  return DropdownButton<String>(
                    hint: const Text('Pilih Kategori'),
                    disabledHint: const Text(
                      'Belum ada kategori untuk tipe ini',
                    ),
                    value: currentValue,
                    isExpanded: true,
                    items: categories.isEmpty
                        ? null
                        : categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                    onChanged: categories.isEmpty
                        ? null
                        : (value) => setState(() => selectedCategory = value),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showAddCategoryDialog,
              child: const Text(
                '+ Tambah Kategori',
                style: TextStyle(
                  color: Color(0xFF355C9A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLength: 255,
              decoration: InputDecoration(
                hintText: 'Tambah Catatan',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355C9A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.transactionToEdit != null
                      ? 'Update Transaksi'
                      : 'Simpan Transaksi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
