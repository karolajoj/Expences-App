import 'package:expenses_app_project/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final CollectionReference expenses = FirebaseFirestore.instance.collection('expenses');

  Future<void> addNewExpense(ExpensesListElementModel newExpense) async {
  final CollectionReference expenses = FirebaseFirestore.instance.collection('expenses');

  try {
    await expenses.add(newExpense.toMap());
    const SnackBar(content: Text('Wydatek został dodany'));
    
  } catch (e) {
    const SnackBar(content: Text('Wystąpił błąd podczas dodawania wydatku'));
  }
  
}
}