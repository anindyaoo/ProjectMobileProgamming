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
