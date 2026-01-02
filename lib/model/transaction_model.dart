import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String userId;
  final String note;
  final double amount;
  final String category;
  final String type; // Pemasukan / Pengeluaran
  final DateTime date;

  TransactionModel({
    this.id,
    required this.userId,
    this.note = '',
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  // Konversi dari Firestore Map ke Model
  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      userId: map['userId'] ?? '',
      note: map['note'] ?? map['title'] ?? '', // Fallback to title for old data
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'Lainnya',
      type: map['type'] ?? 'Pengeluaran',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  // Konversi dari Model ke Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'note': note,
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
    };
  }
}
