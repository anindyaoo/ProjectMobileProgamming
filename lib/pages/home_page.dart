import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'add_transaction_page.dart';

/// =======================
///
/// MODEL TRANSAKSI
/// =======================
class TransactionModel {
  final String title;
  final int amount;
  final String category;
  final String type; // Pemasukan / Pengeluaran
  final DateTime date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// =======================
  /// DATA TRANSAKSI (DUMMY)
  /// =======================
  final List<TransactionModel> transactions = [
    TransactionModel(
      title: 'Gaji',
      amount: 3000000,
      category: 'Lainnya',
      type: 'Pemasukan',
      date: DateTime.now(),
    ),
    TransactionModel(
      title: 'Makan',
      amount: 250000,
      category: 'Makan',
      type: 'Pengeluaran',
      date: DateTime.now(),
    ),
    TransactionModel(
      title: 'Transport',
      amount: 750000,
      category: 'Transport',
      type: 'Pengeluaran',
      date: DateTime.now(),
    ),
  ];

  /// =======================
  /// HITUNG TOTAL
  /// =======================
  int get totalPemasukan => transactions
      .where((t) => t.type == 'Pemasukan')
      .fold(0, (sum, t) => sum + t.amount);

  int get totalPengeluaran => transactions
      .where((t) => t.type == 'Pengeluaran')
      .fold(0, (sum, t) => sum + t.amount);

  int get saldo => totalPemasukan - totalPengeluaran;

  /// =======================
  /// PIE CHART DATA
  /// =======================
  List<PieChartSectionData> buildPieSections() {
    final pengeluaran =
    transactions.where((t) => t.type == 'Pengeluaran').toList();

    if (pengeluaran.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Belum ada',
          color: Colors.grey,
        ),
      ];
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return List.generate(pengeluaran.length, (index) {
      final tx = pengeluaran[index];
      return PieChartSectionData(
        value: tx.amount.toDouble(),
        title: tx.category,
        color: colors[index % colors.length],
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Halo, Anyaa 👋',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== SALDO =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF355C9A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Saat Ini',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    rupiah.format(saldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ===== RINGKASAN =====
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    title: 'Pemasukan',
                    amount: rupiah.format(totalPemasukan),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: summaryCard(
                    title: 'Pengeluaran',
                    amount: rupiah.format(totalPengeluaran),
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ===== PIE CHART =====
            const Text(
              'Pengeluaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: buildPieSections(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionPage(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      transactions.add(
                        TransactionModel(
                          title: result['title'],
                          amount: result['amount'],
                          category: result['category'],
                          type: result['type'],
                          date: result['date'],
                        ),
                      );
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Transaksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355C9A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),


            /// ===== RIWAYAT =====
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(tx.date),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        (tx.type == 'Pengeluaran' ? '- ' : '+ ') +
                            rupiah.format(tx.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tx.type == 'Pengeluaran'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ===== WIDGET CARD RINGKASAN =====
  Widget summaryCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
