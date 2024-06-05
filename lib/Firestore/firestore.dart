import 'package:expenses_app_project/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addNewExpense(ExpensesListElementModel newExpense) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      final ExpensesListElementModel expenseWithUid = ExpensesListElementModel(
        data: newExpense.data,
        sklep: newExpense.sklep,
        kategoria: newExpense.kategoria,
        produkt: newExpense.produkt,
        ilosc: newExpense.ilosc,
        cena: newExpense.cena,
        miara: newExpense.miara,
        miaraUnit: newExpense.miaraUnit,
        iloscWOpakowaniu: newExpense.iloscWOpakowaniu,
        kosztDostawy: newExpense.kosztDostawy,
        zwrot: newExpense.zwrot,
        link: newExpense.link,
        komentarz: newExpense.komentarz,
      );

      final CollectionReference userExpenses = FirebaseFirestore.instance
          .collection("MainCollection")
          .doc(user.displayName)
          .collection("expenses");

      await userExpenses.add(expenseWithUid.toMap());
    } catch (e) {
      // Pokaż błąd za pomocą SnackBar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Wystąpił błąd podczas dodawania wydatku')),
      // );
    }
  }
}