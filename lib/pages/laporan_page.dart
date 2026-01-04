import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';

class HalamanLaporanPage extends StatelessWidget {
  const HalamanLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final TransactionController controller = Get.find<TransactionController>();

    // Format mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF355C9A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        // Jika data sedang loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= FILTER =================
              Row(
                children: [
                  _buildDropdown('Bulan'),
                  const SizedBox(width: 8),
                  _buildDropdown('Tahun'),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Unduh PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= SUMMARY CARD (DATA ASLI) =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryItem(
                          'Total Masuk',
                          currencyFormatter.format(controller.totalIncomeThisMonth),
                          Colors.green.shade100,
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryItem(
                          'Total Keluar',
                          currencyFormatter.format(controller.totalExpenseThisMonth),
                          Colors.red.shade100,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Saldo Bersih',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormatter.format(controller.currentBalance),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= LIST TRANSAKSI (DATA ASLI) =================
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: controller.transactions.isEmpty
                    ? const Center(child: Text("Tidak ada transaksi"))
                    : ListView.builder(
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final trx = controller.transactions[index];

                    // MENGATASI ERROR:
                    // Kita gunakan trx.category. Jika error lagi, ganti ke trx.description
                    return _TransactionItem(
                      date: DateFormat('dd MMM yyyy').format(trx.date),
                      title: trx.category,
                      amount: (trx.type == 'Pemasukan' ? '+ ' : '- ') +
                          currencyFormatter.format(trx.amount),
                      isIncome: trx.type == 'Pemasukan',
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // --- Widget Bantuan ---

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox(),
        hint: Text(hint),
        items: const [],
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String date;
  final String title;
  final String amount;
  final bool isIncome;

  const _TransactionItem({
    required this.date,
    required this.title,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}