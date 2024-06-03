import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference expenses = FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(String name, double price) async {
    await expenses.add({
      'name': name,
      'price': price,
    });
  }
}