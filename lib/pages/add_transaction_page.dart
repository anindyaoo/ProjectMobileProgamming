import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import '../model/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../controllers/transaction_controller.dart';
import 'main_page.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Use Controller instead of Service directly
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
          title: const Text('Tambah Kategori'),
          content: TextField(
            controller: newCategoryController,
            decoration: const InputDecoration(
              hintText: 'Nama Kategori Baru',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = newCategoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  transactionController.addCategory(newCategory);
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
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    final amount = CurrencyInputFormatter.parseFormattedValue(
      amountController.text,
    );

    if (amount <= 0 ||
        selectedCategory == null ||
        !transactionController.categories.contains(selectedCategory)) {
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

    // Use Controller to Save/Update
    if (widget.transactionToEdit != null) {
      await transactionController.updateTransaction(
        widget.transactionToEdit!.id!,
        newTransaction,
      );
    } else {
      await transactionController.addTransaction(newTransaction);
    }

    // Redirect to Transaction Tab
    Get.offAll(() => const MainPage(initialIndex: 1));
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
        automaticallyImplyLeading: true, // Show back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== TIPE TRANSAKSI =====
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
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// ===== NOMINAL =====
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

            /// ===== KATEGORI =====
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
                  final categories = transactionController.categories;

                  if (categories.isEmpty) {
                    return const Center(child: Text('Belum ada kategori'));
                  }

                  // Ensure selectedCategory is in the list, otherwise null to prevent crash
                  String? currentValue = selectedCategory;
                  if (currentValue != null &&
                      !categories.contains(currentValue)) {
                    currentValue = null;
                  }

                  return DropdownButton<String>(
                    hint: const Text('Pilih Kategori'),
                    value: currentValue,
                    isExpanded: true,
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategory = value),
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

            /// ===== TANGGAL =====
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
                      DateFormat('dd/MM/yyyy').format(selectedDate),
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

            /// ===== CATATAN =====
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

            /// ===== TOMBOL SIMPAN =====
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
