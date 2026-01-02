import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:personal_finance/controllers/transaction_controller.dart';
import 'add_transaction_page.dart';
import '../model/transaction_model.dart';
import '../utils/currency_formatter.dart';

class TransactionPage extends GetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF355C9A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('Semua'),
                  _buildFilterButton('Hari Ini'),
                  _buildFilterButton('Bulan Ini'),
                ],
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = controller.filteredTransactions;

              if (transactions.isEmpty) {
                return const Center(
                  child: Text('Tidak ada transaksi untuk periode ini'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _buildTransactionItem(tx);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = controller.selectedFilter.value == text;
    return GestureDetector(
      onTap: () {
        controller.updateFilter(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF355C9A) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          /// ===== TRANSACTION INFO (LEFT) =====
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('d MMM yyyy').format(tx.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tx.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tx.note,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      const Text(
                        '-',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${tx.type == 'Pemasukan' ? '+ ' : '- '}${CurrencyInputFormatter.formatAmount(tx.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: tx.type == 'Pemasukan' ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// ===== EDIT ICON (RIGHT) =====
          Tooltip(
            message: 'Edit Transaksi',
            child: InkWell(
              onTap: () {
                Get.to(() => AddTransactionPage(transactionToEdit: tx));
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.edit, size: 24, color: Color(0xFF355C9A)),
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// ===== DELETE ICON (RIGHT) =====
          Tooltip(
            message: 'Hapus Transaksi',
            child: InkWell(
              onTap: () {
                Get.defaultDialog(
                  title: 'Hapus Transaksi',
                  middleText:
                      'Apakah Anda yakin ingin menghapus transaksi ini?',
                  textConfirm: 'Ya',
                  textCancel: 'Batal',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    Get.find<TransactionController>().deleteTransaction(tx.id!);
                    Get.back();
                  },
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.delete, size: 24, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
