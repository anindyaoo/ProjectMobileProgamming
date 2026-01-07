import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart';
import '../model/category_model.dart';

// Abstraction: Abstract base class defining the contract
abstract class TransactionRepository {
  Future<void> addCategory(String categoryName, String type);
  Stream<List<CategoryModel>> getCategories();
  Future<void> addTransaction(TransactionModel transaction);
  Stream<List<TransactionModel>> getTransactions(String userId);
  Future<void> deleteTransaction(String id);
  Future<void> deleteAllTransactions(String userId);
  Future<void> updateTransaction(String id, TransactionModel transaction);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(String id, String name, String type);
}

// Inheritance & Polymorphism: Implementing the interface
class FirestoreService implements TransactionRepository {
  // Encapsulation: Private fields
  final CollectionReference _transactions = FirebaseFirestore.instance
      .collection('transactions');
  final CollectionReference _categories = FirebaseFirestore.instance.collection(
    'categories',
  );

  @override
  Future<void> addCategory(String categoryName, String type) {
    return _categories.add({'name': categoryName, 'type': type});
  }

  @override
  Future<void> deleteCategory(String id) {
    return _categories.doc(id).delete();
  }

  @override
  Future<void> updateCategory(String id, String name, String type) {
    return _categories.doc(id).update({'name': name, 'type': type});
  }

  @override
  Stream<List<CategoryModel>> getCategories() {
    return _categories.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) {
    return _transactions.add(transaction.toMap());
  }

  @override
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _transactions.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final transactions = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Sort by date descending (Client-side sorting to avoid Firestore Index requirement)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    });
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _transactions.doc(id).delete();
  }

  @override
  Future<void> deleteAllTransactions(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    var snapshots = await _transactions
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> updateTransaction(String id, TransactionModel transaction) {
    return _transactions.doc(id).update(transaction.toMap());
  }
}
