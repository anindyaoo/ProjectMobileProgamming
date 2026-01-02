import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:personal_finance/controllers/auth_controller.dart';
import 'package:personal_finance/controllers/transaction_controller.dart';
import 'add_transaction_page.dart';
import '../model/transaction_model.dart';
import '../utils/currency_formatter.dart';

class HomePage extends GetView<TransactionController> {
  const HomePage({super.key});

  final List<Color> incomeColors = const [
    Color(0xFF2E7D32), // Green 800
    Color(0xFF43A047), // Green 600
    Color(0xFF66BB6A), // Green 400
    Color(0xFF00695C), // Teal 800
    Color(0xFF26A69A), // Teal 400
    Color(0xFF0277BD), // Light Blue 800
  ];

  final List<Color> expenseColors = const [
    Color(0xFFC62828), // Red 800
    Color(0xFFE53935), // Red 600
    Color(0xFFEF5350), // Red 400
    Color(0xFFAD1457), // Pink 800
    Color(0xFFEC407A), // Pink 400
    Color(0xFFAB47BC), // Purple 400
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        title: Obx(() {
          final user = AuthController.instance.currentUserData.value;
          final username = user?.username ?? 'User';
          return Text(
            'Halo, $username 👋',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = controller.transactions;
        // Filter Bulan Ini
        final now = DateTime.now();
        final thisMonthTransactions = transactions.where((t) {
          return t.date.month == now.month && t.date.year == now.year;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== SALDO =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF355C9A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF355C9A).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Saldo Saat Ini',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyInputFormatter.formatAmount(
                        controller.currentBalance,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== TOMBOL TAMBAH =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const AddTransactionPage());
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355C9A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ===== RINGKASAN =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Bulan Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pemasukan'),
                        Text(
                          CurrencyInputFormatter.formatAmount(
                            controller.totalIncomeThisMonth,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pengeluaran'),
                        Text(
                          CurrencyInputFormatter.formatAmount(
                            controller.totalExpenseThisMonth,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ===== CHART =====
              const Text(
                'Statistik Pengeluaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Pie Chart Logic
              if (thisMonthTransactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Belum ada data transaksi bulan ini'),
                  ),
                )
              else
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _getSections(thisMonthTransactions),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  List<PieChartSectionData> _getSections(List<TransactionModel> transactions) {
    // Filter expenses only
    final expenses = transactions
        .where((t) => t.type == 'Pengeluaran')
        .toList();

    if (expenses.isEmpty) return [];

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final totalExpense = categoryTotals.values.fold(
      0.0,
      (sum, item) => sum + item,
    );

    int colorIndex = 0;
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalExpense) * 100;
      final color = expenseColors[colorIndex % expenseColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
